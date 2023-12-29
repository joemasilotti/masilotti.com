---
title: Mocking classes you don't own in Swift
date: 2016-01-11
description: Not owning a class doesn't mean you can't mock it! Learn how to unit test URLSession with Swift and protocol-oriented programming.
series: testing-nsurlsession
---

My go-to approach when unit-testing Swift is [protocol-oriented programming](https://developer.apple.com/videos/play/wwdc2015-408/). As requested by you, let's see a real-world example. What better way to show some code than with the networking stack, something every iOS developer has dealt with!

{% include series.liquid %}

## Don't fear the session!

If you are developing anything targeting iOS or tvOS 9.0 and start networking code, you will notice that the `NSURLConnection` APIs are officially deprecated. My go-to method, `sendAsyncronousRequest()`, will need to be replaced with `dataTask(with:)`. 

If you haven't worked with `URLSession` yet, no worries. There are only two major components you'll need to understand to follow along.

The main interface to the API, `URLSession`, can be used in a very similar manner to `NSURLConnection`. That is, with asynchronous blocks and no delegates. We will focus on `dataTask(with:)` from a bare bones instantiation to retrieve data from the network.

This method returns an instance of `URLSessionDataTask`. Think of these as in-flight network requests. Most importantly, they can be started, paused, cancelled, and resumed.

Here's a naive approach to sending a request to my site and printing the response. 

``` swift
let session = URLSession.shared
let url = URL(string: "http://masilotti.com")!
let task = session.dataTask(with: url) { (data, _, _) -> Void in
    if let data = data {
        let string = String(data: data, encoding: String.Encoding.utf8)
        print(string ?? "(no data)")
    }
}
task.resume()
```

Not so bad, right? This method has a few limitations, but we can start with it as a building block to bigger and better queries.

> After you create a task, you start it by calling its resume method. - [URLSessionTask docs](https://developer.apple.com/library/ios/documentation/Foundation/Reference/URLSessionTask_class/index.html)

As you read through the post, feel free to [follow along with the commits on GitHub](https://github.com/joemasilotti/TestingURLSession). Unfortunately XCTest is a pain to use with playgrounds so it's just an Xcode project.

## Possible testing approaches

Our goal is to unit test the interface to `URLSession`. To do so , we will create a new object, `HTTPClient`, that interacts with the session. The rest of the app's code will interact with `HTTPClient` directly.

Possible ways to test the session:

1. Full integration tests that hit the network
2. Subclass `URLSession`
3. Mock `URLSession` via a new protocol

### Integration tests that hit the network

Perhaps the simplest way to test the session is by letting it access the network. The request could hit a known endpoint on your server, say `/ios-test`. Then you can assure that the response is parsed into valid JSON or model objects. While easy to set up, this approach has a few downsides.

First, the tests will take much longer to run. If you have a poor network connection they will take even longer. This technique could easily add chunks of time to your previously blazing-fast test suite. Not to mention that the tests will fall over if you lose your internet connection!

Asynchronous tests are also not reliable. The more tests you have the higher the likelihood one or more will fail randomly. Use something like [UI Testing]({% post_url 2015-06-29-ui-testing-xcode-7 %}) if you want to write full integration tests.

#### Subclass `URLSession`

By subclassing you can easily add flags to check which methods are called with which parameters. However, if you don't override **every single** method, you are using an object under test that has real functionality. This means your test suite could be accessing the network or other crazy things without you being aware.

This approach becomes unscalable when dealing with Apple's framework. Every iOS release you will have to go back to all of your subclasses and update them for each new method that was added. If Apple changes the functionality under the hood your tests could also fail for unexpected reasons.

### Mock `URLSession` with a protocol

Mocking the session under test relieves us of the problems that burden the other techniques. The network will never be hit, no functionality will be executed, and we won't have to update the mock when Apple adds new methods.

## IDEPEM

To accomplish this we will follow my coined acronym, **IDEPEM**. This stands for **i**nject **d**ependencies, **e**verything's a **p**rotocol, **e**quatable **m**ocks.

<p class="note">Read through <a href="{% post_url 2020-03-31-better-swift-unit-testing %}">Better Unit Testing with Swift</a> for a deeper dive into why I chose this approach.</p>

To do this, we will need to create a few extra protocols and intermediary objects.

1. `HTTPClient` needs to work with an `URLSession`
2. `URLSession` needs to conform to a protocol so we can mock it under test
3. We need to mock `URLSessionDataTask` so we can assert `resume()` is called

### Make `URLSession` testable

Ideally, the interface to `URLSession` would be protocol based. We could create a mock object that conformed to this protocol and use the objects interchangeably under test.

Unfortunately, Apple hasn't *fully* embraced protocol-oriented programming in its framework code. No worries; we’ll create our own protocol, and have `URLSession` conform to it via an extension.

#### Create the protocol

First, let's create a protocol that Apple's `URLSession` can conform to.

``` swift
typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

protocol URLSessionProtocol {
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) -> URLSessionDataTask
}
```

> **Note**: We purposely give the function a different name than the actual implementation. This is to avoid a infinite loop when we extend `URLSession` to conform to out protocol.

Second, give the client a session via dependency injection.

``` swift
class HTTPClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    // ... //
}
```

Now when we test `HTTPClient` we can inject any implementation of the `URLSessionProtocol` we choose. In our production code we don't have to worry about creating a conforming object manually as the default parameter will instantiate an `URLSession` for us!

But wait, we seem to have an error.

![NSURLSession exception](/assets/images/testing-nsurlsession-input/nsurlsession-exception.png){:standalone .unstyled}

> Default argument value of type 'URLSession' does not conform to 'URLSessionProtocol'

Mimicking the interface to `URLSession` in our protocol isn't enough. We have to tell the compiler that it conforms to our protocol. We accomplish this with an empty protocol extension on Apple's session.

``` swift
extension URLSession: URLSessionProtocol {}
```

We don't actually have to implement anything in this extension because we kept the method signature the same as Apple's framework. Meaning, `URLSession` already implements our protocols required methods.

#### Create a mock for tests

Now that we can inject any concrete implementation of `URLSessionProtocol`, let's create a mock to track method calls. We can use this under test to ensure the right methods were called on the session with the right parameters.

``` swift
class MockURLSession: URLSessionProtocol {
    private (set) var lastURL: URL?

    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) -> URLSessionDataTask {
        lastURL = url
        return URLSession.shared.dataTask(with: url)
    }
}
```

When `dataTask(with:)` is called we take note of the URL that was passed in. We can then interrogate this later to assert the method was called with the correct parameter.

> Make sure to import your Swift module in your mocks and tests with:
> 
>  `@testable import <MAIN_MODULE>`

#### Test the URL

With dependency injection and our mock in place, the test almost writes itself.

``` swift
class HTTPClientTests: XCTestCase {
    var subject: HTTPClient!
    let session = MockURLSession()

    override func setUp() {
        super.setUp()
        subject = HTTPClient(session: session)
    }

    func test_GET_RequestsTheURL() {
        let url = URL(string: "http://masilotti.com")!

        subject.get(url: url) { (_, _, _) -> Void in }

        XCTAssertEqual(session.lastURL, url)
    }
}
```

We create a mock session and inject it into the subject under test. Then we call the stimulus, `get()`, with a referenced URL. Finally, we assert that the URL the session received was the same one we passed in.

``` swift
class HTTPClient {
    // ... //

    func get(url: URL, completion: @escaping DataTaskResult) {
        session.dataTaskWithURL(_: url, completion: completion)
    }
}
```

This gets us pretty far in terms of testing `URLSession`. We can easily extend this approach to work with `requestWithRequest()` and start asserting more information on the `URLRequest`. However, we still haven't tested anything on the returned `URLSessionDataTask`, such as the call to `resume()`.

### Make `URLSessionDataTask` testable

We can follow the same approach to start testing the data task.

1. Create the protocol
2. Extend the base class
3. Create the mock

``` swift
protocol URLSessionDataTaskProtocol {
    func resume()
}
```

``` swift
extension URLSessionDataTask: URLSessionDataTaskProtocol { }
```

``` swift
class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false

    func resume() {
        resumeWasCalled = true
    }
}
```

Now things get a little hairy. We need our `URLSessionProtocol`'s method to return our protocol, not Apple's base class. Let's modify the protocol to do just that.

``` swift
protocol URLSessionProtocol {
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult)
      -> URLSessionDataTaskProtocol
}
```

Uh-oh, looks like we are back to the same error as before.

![NSURLSession exception](/assets/images/testing-nsurlsession-input/nsurlsession-exception.png){:standalone .unstyled}

> Default argument value of type 'URLSession' does not conform to 'URLSessionProtocol'

Even though the error message is the same, the root cause is actually a little different.

#### Extend `URLSession` to handle the new protocol

The error is occurring because `URLSession` doesn't have a `dataTaskWithURL()` method that returns our custom protocol. To fix this, we just need to extend the class a little differently.

``` swift
extension URLSession: URLSessionProtocol {
    func dataTaskWithURL(_ url: URL, completionHandler: @escaping DataTaskResult)
      -> URLSessionDataTaskProtocol 
    {
        dataTask(with: url, completionHandler: completion) as URLSessionDataTaskProtocol
    }
}
```

Here we implement the method in the protocol manually. But instead of doing any actual work, we call back to the original implementation and cast the return value. The cast doesn't need to be implicit because our protocol already conforms to Apple's data task. Win-win!

#### Update the session mock to return a data task

Now that our `URLSessionProtocol` returns a custom object, we need the ability to stub it out under test. We do this by adding a publicly-writable property on the mock that is returned when the method is called.

``` swift
class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask()
    private (set) var lastURL: URL?

    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = url
        return nextDataTask
    }
}
```

The property is defaulted to something so we don't have to worry about setting it if we don't need it in our test. "It's there when you need to set it, but gets out of the way when you don't."

#### Test that `resume()` was called

With everything in place we can now test that the data task was started.

``` swift
class HTTPClientTests: XCTestCase {
  // ... //

  func test_GET_StartsTheRequest() {
      let dataTask = MockURLSessionDataTask()
      session.nextDataTask = dataTask

      let url = URL(string: "http://masilotti.com")!
      subject.get(url: url) { (_, _, _) -> Void in }

      XCTAssert(dataTask.resumeWasCalled)
  }
}
```

We create a reference to our mock data task and assign it to the session. After calling the stimulus, we assert that the `resumeWasCalled` flag was set on the data task.

``` swift
class HTTPClient {
    // ... //

    func get(url: URL, completion: DataTaskResult) {
        session.dataTaskWithURL(url, completion: completion).resume()
    }
}
```

> **Pro tip**: Using `HTTPClient` in an Xcode playground? Add the following two lines to allow the network request to finish.
>
> ``` swift
> import XCPlayground
>
> XCPSetExecutionShouldContinueIndefinitely(true)
> ```

## Recap

We took the **IDEPEM** approach to getting `URLSession` in a test harness. First, we made sure the session conformed to our custom protocol with an extension. Then we created a mock and injected it under tests. Finally, we farther extended the class to work with `URLSessionDataTask`.

### But…

Seems like a lot of work to test, what, **two** lines of code? I agree!

Think of this post as your *approach* to testing `URLSession`, not an actual framework or library. You know, "teach a person to fish" and all that.

Don't believe me? Try extending this technique to test `dataTaskWithRequest()`. I bet you already know how to start and have a pretty good outline in your head. If you run into issues, feel free to leave a comment below and I'll help you through it.

## What's next?

Everything we've tested so far is only related to the *input* of the method. What happens when the network connection fails? Or returns JSON that we want to parse?

In part two we take a look at the response, `DataTaskResult`. We go over testing response `Data` and handling network errors. And the best part? We do all of this without any asynchronous code in our tests. Read the next post on [testing `URLSession` with Swift, flattening asynchronous tests]({% post_url 2016-02-01-testing-nsurlsession-async %}).
