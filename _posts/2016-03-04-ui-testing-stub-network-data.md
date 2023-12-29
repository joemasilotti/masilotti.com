---
title: UI Testing with stubbed network data
date: 2016-03-04
description: Learn how to stub network data when running UI Tests with the magic of some "secret" XCTest APIs.
series: testing-nsurlsession
---

We've all been there. We get super excited to try out UI Testing and start to use it for all the app's flows. And then one of the tests requires the user to be logged in.

What do we do? Have a "test user" whose password never changes? Create a mock server? Forget the test entirely? There's got to be something better!

With just a little bit of code, we can stub out network data when running our UI Tests. How? With the magic of some "secret" XCTest APIs.

A quick overview of what we will cover:

1. Stub requests with a `URLSession` subclass
1. Inject the stubbed `URLSession` into our networking layer
1. Use the "secret" XCTest API to tie it all to UI Testing

{% include series.liquid %}

## Ramping up

This is part three of a series of posts on testing `URLSession`. If you haven't already read how to [mock classes you don't own]({% post_url 2016-01-11-testing-nsurlsession-input %}) and [flatten asynchronous tests]({% post_url 2016-02-01-testing-nsurlsession-async %}), I suggest you do that now. 

To recap, we learned how to use [IDEPEM]({% post_url 2020-03-31-better-swift-unit-testing %}#recap-idepem) to create protocols that our test mocks can conform to. Then we injected a real session in our production app. Finally, we made a few assertions on the returned `URLSessionDataTask`.

Next we discussed the problems with hitting the network under test. We injected a fake `URLSession` that immediately executes its callbacks to speed up our test suite. This enables our networking tests to occur almost instantaneously and much more reliable.

### Diving right in

If you haven't built out the code, you can checkout the GitHub repository at the [`part-3` tag](https://github.com/joemasilotti/TestingURLSession/releases/tag/part-3). This includes a working HTTP client with flattened asynchronous tests.

As you read through the post, feel free to [follow along with the commits on GitHub](https://github.com/joemasilotti/TestingURLSession). Unfortunately XCTest is a pain to use with playgrounds so it's just an Xcode project.

## Why we shouldn't be hitting the network

Just like our unit tests, UI Tests should be [fast, isolated, and repeatable](https://pragprog.com/magazines/2012-01/unit-tests-are-first). When hitting the network, we introduce variables that our out of our control. This leads us to slow and nondeterministic tests which make it hard to verify error scenarios.

Even though UI Testing is already notoriously slow, there's no need to make it even worse. Accessing the network is guaranteed to **add seconds to your test suite, perhaps minutes** if your server is slow. Now imagine if you're trying to work from a coffee shop with slow Wi-Fi!

The unreliability of your network will **make your tests nondeterministic**. Your test suite becomes less dependent on your application code and relies more on the state of your machine and connectivity. This can introduce the classic "it works on my machine" issue but is easily avoided.

Finally, **how can you reliably test server errors?** Or network errors? You could easily start building up a lot of fragile scaffolding on your QA or staging server to accommodate this. Instead, let's bake it in to the testing framework itself and leave the code on the client.

Now that I've convinced you, how can we get UI Testing to help us start stubbing requests?

## Possible testing approaches

### Mocking the `HTTPClient`

Our first attempt will be to mock our `HTTPClient` responses just like normal unit tests.

You will have an `HTTPClient` that acts as the main interface to all networking if you've been following along with the previous posts. If not, no worries, here's the interface.

```swift
typealias HTTPResult = (Data?, ErrorType?) -> Void

class HTTPClient {
    init(session: URLSessionProtocol = URLSession.defaultSession())
    func get(url: URL, completion: HTTPResult)
}
```

To test this approach add `HTTPClient` to your UI Test target. Once it's there we can access it by importing the production code with the `@testable` mark.

```swift
@testable import TestHost
```

Great! Now we can access the production code under test. Let's try and mock out our response. We just need to grab a reference to the client. We can do that by… wait, what? How are we supposed to know which instance of the client the test is going to use?

Short answer is that we don't. Our app could create many of these instances during its lifecycle but we have no control over where or when they are instantiated.

#### `HTTPClient` singleton

OK, let's break a small rule and make our client a singleton. It's all in the name of testing!

```swift
class HTTPClient {
    static let sharedInstance = HTTPClient()

    // ...
}
```

While that gives us a nice reference to the same client every time, it lacks one important detail. There is no way to inject our fake session any more. Now when we instantiate `HTTPClient` in our UI Tests it will always have the "real" session. That doesn't help much!

### `OHHTTPStubs`

Instead of trying to mock the requests ourselves let's let a framework do it for us!

[`OHHTTPStubs`](https://github.com/AliSoftware/OHHTTPStubs) is the de facto tool for stubbing the network when writing  unit tests in both Objective-C and Swift. Under the hood it uses method swizzling to [rewrite some of the routing of `URLSession` via `URLSessionProtocol`](https://github.com/AliSoftware/OHHTTPStubs#automatic-loading).

The wiki includes some detailed instructions [getting your app set up with UI Testing](https://github.com/AliSoftware/OHHTTPStubs/wiki/A-tricky-case-with-Application-Tests). After a lot of fiddling in the Project Manager this actually works. Rejoice! However, it comes with a two major caveats.

First off, the set up is non trivial. You are required to add certain pieces of the framework to certain targets in your app. The procedure becomes even more intricate when you want an instance for your Unit Test target. There are lots of potential areas for linker errors which are never fun to debug.

Also, you are adding the *entire mocking framework* to your application code. This, well, this scares me. What happens if a mocked response leaks in to my production code? What if I mocked that one tiny error case that I never see during normal testing, but happens all the time to some users?

Granted, the wiki notes how you can work around this. The developers recommend ["resetting" your stubs when your app launches](https://github.com/AliSoftware/OHHTTPStubs/wiki/A-tricky-case-with-Application-Tests#a-workaround-if-you-really-need-it) to ensure this exact scenario never occurs. This approach requires some magic strings for gaining access to the class name and will not be compiler time type safe. I'll let you decide if it's worth brining in to your code.

### Mock server, running locally

Let's switch gears. Instead of relying on the code in Xcode let's push the responsibility somewhere else.

A popular approach to stubbing network requests is to, well, not stub them at all! Instead, have an entire environment where *everything* is seeded. Have POSTs to `/users/new` always return a 200 with user 5. Make GETs to `/users/5/posts/17` always return a 404. You can quickly build up a bunch of contrived scenarios to test a large surface area of your application.

However, this comes with trade-offs. First, theres a small amount of set up required to get the server to expose these endpoints when running in "mock mode." This could also potentially leak in to your production code base if you aren't careful.

Second, you run the risk of the response data diverging from the *actual* response. As your server code is iterated on things could change. It could be as obvious as a new API version or as trivial as changing a string to an integer in some JSON. For fast-moving teams this can be even harder to keep track of as the app grows. You could end up relying on seeded data that in no way represents what happens when the app hits the server "for real."

Finally, it's hard to test for error scenarios. What happens when you want to test a POST to `/users/new` for both 200 and 500 responses? This can easily snowball into lots of code on your server just to manage the sequencing of requests.

### Is there something better?

Two out of three of these approaches work. However, in my opinion their disadvantages far outweigh the solution to the problem they are trying to solve. Instead of trying to work around UI Testing let's take a closer look at the framework. Maybe something in the [XCTest documentation](https://developer.apple.com/documentation/xctest) will give us a hint.

Peeking under the covers, we notice a few classes directly related to UI Testing. One that stands out in particular is [`XCUIApplication`](https://developer.apple.com/documentation/xctest/xcuiapplication). Here we note a few familiar faces, `launch()` and `terminate()`. But also two other interesting properties, `launchArguments` and `launchEnvironment`. *What are those?*

## Working with `launchEnvironment`

From the [documentation](https://developer.apple.com/documentation/xctest/xcuiapplication/1500427-launchenvironment):

> `var launchEnvironment: [String : String] { get set }`
>
> If not modified, these are the environment variables that Xcode will pass to the application on launch. The environment variables can be changed, added to, or removed. Unlike [Process](https://developer.apple.com/documentation/foundation/process), it is also legal to modify the environment variables after the application has been launched. Such changes will not affect the current launch session, but will take effect the next time the application is launched.

Big deal. What does this actually mean? To start, this opens up a small "back door" to our production code from our UI Tests. And while it might not sound like a lot, it's actually quite a big deal.

So, how do we use this new fangled API? I'm glad you asked. First, set the key-value pair in your UI Test. Remember, as the documentation states, do this *before* launching the app.

```swift
class UITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app.launchEnvironment["AnswerToLife"] = "42"
        app.launch()
    }

    // ...
}
```

This dictionary is then exposed via the `environment` property via  `ProcessInfo`. Access the string the same as any other dictionary in your production code.

```swift
if let answerToLife = ProcessInfo.processInfo.environment["AnswerToLife"] {
    print(answerToLife)
}
```

Alright! Now that we have a way of passing data to our application, how can we use it to stub network requests?

## Implementing a stubbed URL session

To actually stub out requests we need to add a tiny bit of code to our production app. It will be three small classes which total about 40 lines of code.

### `SeededURLSession`

The simplest way to make a network request with `URLSession` is `dataTaskWithURL(_, completionHandler:)`. For now, let's assume that every request is routing through that method.

```swift
typealias DataCompletion = (Data?, URLResponse?, Error?) -> Void

class SeededURLSession: URLSession {
    override func dataTaskWithURL(url: URL, completionHandler: (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return SeededDataTask(url: url, completion: completionHandler)
    }
}
```

We are subclassing `URLSession` to override `dataTaskWithURL()` to return a custom object, `SeededDataTask`. We also type-alias the completion block for readability.

Next, let's implement `SeededDataTask`. This, my lovely readers, is where the magic happens.

```swift
class SeededDataTask: URLSessionDataTask {
    private let url: URL
    private let completion: DataCompletion

    init(url: URL, completion: @escaping DataCompletion) {
        self.url = url
        self.completion = completion
    }

    override func resume() {
        if let json = ProcessInfo.processInfo.environment[url.absoluteString] {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let data = json.data(using: .utf8)
            completion(data, response, nil)
        }
    }
}
```

Again, hopefully very straightforward! When a `URLSessionDataTask` is created we must call `resume()` on it to kick off the networking. Now the subclass will first look for some JSON shoved in the `launchEnvironment`!

### Setting the JSON response in UI Tests

We can now easily stub out requests in our UI Test setup method. Remember, set the launch environment *before* the app is launched. Oh, let's also add a flag to the launch *arguments* so our app knows when we are UI Testing.

```swift
class UITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        // ...

        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["http://masilotti.com/api/posts.json"] = "{\"posts\": \(postCount)}"
        app.launch()
    }
}
```

For now we can write represent the JSON as a full string. If your response is more complicated you could write structured JSON then convert it to a string. Or read it from disk.

#### What happened to my equal signs?

As mentioned by Nicholas Pachulski, equal signs don't translate well via the launch environment. See his [post on the subject](http://pachulski.me/2016/addendum-to-ui-testing-with-stub-network-data/) for a quick and easy workaround.

### Using the stubbed session under test

OK, now we are getting somewhere. We have a reliable way to stub our requests and can set a distinct response for each URL. But how do we tell the app to actually *use* our beautifully crafted session?

We do this by adding just a few more lines of code to our production app. First, a new object, `Config.` This acts as a minuscule "injector" for dependency injection.

```swift
struct Config {
    static let urlSession: URLSession = UITesting() ?
        SeededURLSession() : URLSession.defaultSession()
}

private func UITesting() -> Bool {
  ProcessInfo.processInfo.arguments.contains("UI-TESTING")
}
```

Like I said, simple, right! We create a static method to check if we are actually UI Testing by looking for the magic string in the launch arguments. Whenever a client asks for `Config.urlSession` they are given the seeded one under test. Otherwise they receive real one.

### Injecting the seeded session

The final step ties all the loose ends together. Now that we have a way of determining *which* session to use, we actually have to *use* it.

```swift
class HTTPClient {
    private let session: URLSession

    init(session: URLSession = Config.urlSession) {
        self.session = session
    }

    // ...
}
```

And that's it! Our `HTTPClient` is injected with the correct session based on our environment. And we didn't lose any functionality regarding dependency injection for unit tests.

## Recap

It took us a little while to get here, but we now have a nice, little framework for stubbing network requests when UI Testing. To recap, we

1. Added JSON to `launchEnvironment`, keyed off of the URL
1. Created a `SeededURLSession` to return the JSON if the URL matches
1. Used `Config` to determine *which* `URLSession` to use
1. Injected the correct session to `HTTPClient`

I think that adding a tiny bit of code to your production app is a small price to pay for the added functionality.

## What's next?

To keep the code small and concise `SeededURLSession` is always returning a 200 response. You could extend this technique to bake in the status code to the URL when seeding the response. Then you enable your framework to test all sorts of errors.

Nothing happens if a URL attempting to be stubbed doesn't have JSON associated with it. You could extend `SeededURLSession` to fallback to using the "real" `URLSession` in these scenarios.
