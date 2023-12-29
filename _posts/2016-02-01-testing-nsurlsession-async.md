---
title: Flattening Asynchronous Tests
date: 2016-02-01
description: Shave time off your test suite by flattening asynchronous tests. Learn how to mock more of URLSession to test response data, network errors, and status codes.
series: testing-nsurlsession
---

You've sent your fully tested HTTP request off into the wild. Now, what happens when it returns? How do you test for response data? What about network errors? Server errors? Let's take a look at how to test these network responses, and more, in this second post on testing `URLSession`.

{% include series.liquid %}

## Ramping up

This is part two of a series of posts on testing `URLSession`. If you haven't already read the [first part on mocking classes you don't own]({% post_url 2016-01-11-testing-nsurlsession-input %}) I suggest you do that now. 

To recap, we learned how to use [IDEPEM]({% post_url 2020-03-31-better-swift-unit-testing %}#recap-idepem) to create protocols that our test mocks can conform to. Then we injected a real session in our production app. Finally, we were able to make a few assertions on the returned `URLSessionDataTask`.

If you haven't built out the code from [part 1]({% post_url 2016-01-11-testing-nsurlsession-input %}) you can checkout the GitHub repository at commit [ecb11de](https://github.com/joemasilotti/TestingURLSession/commit/ecb11dee529b04992ddd7120e6d9fc8506876eeb). This includes a working HTTP client with accompanying tests.

As you read through the post, feel free to [follow along with the commits on GitHub](https://github.com/joemasilotti/TestingURLSession). Unfortunately XCTest is a pain to use with playgrounds so it's just an Xcode project.

## Waiting for expectations

The quickest way to test network requests is to just run them. Yep, you heard me right, let's have our test suite actually hit the network. To start, let's make sure we can get data from this website.

``` swift
func test_GET_ReturnsData() {
    let url = URL(string: "https://masilotti.com")!
    var data: Data?

    URLSession.shared.get(url) { (theData, error) -> Void in
        data = theData
    }

    XCTAssertNotNil(data)
}
```

Simple, enough, right? We call into our `HTTPClient` with a URL and make sure we get some data when the method calls its completion handler. Remember, we already have our `HTTPClient` implemented. We should be able to run these tests and see everything go green. Right?

![URLSession Asynchronous Test Failure](/assets/images/testing-nsurlsession-async/nsurlsession-async-failure.png){:standalone}

Hmm, it seems testing the network request isn't so simple. Well, what's going on here?

By default, Xcode's test runner executes your tests in one thread, never stopping or waiting for anything. Kind of like [Blaine the Mono](http://darktower.wikia.com/wiki/Blaine_the_Mono). This means that by the time the network request finishes loading Xcode has already considered our test a failure.

Fortunately, we don't need to win a riddling contest with Xcode to make it do what we need. With the help from a fairly new API we can tell Xcode to wait for a certain period of time.

### Enter XCTest expectations

Something magical happened when Xcode 6 was released. Apple decided to put a little more focus on their XCTest suite and added some bells and whistles. The most important, in my opinion, was the ability to test asynchronous code.

The [documentation on `XCTestCase`](https://developer.apple.com/documentation/xctest/xctestcase) comments on the new category's functionality (emphasis mine).

> This category introduces support for asynchronous testing in XCTestCase. The mechanism allows you to specify one or more "expectations" that will **occur asynchronously as a result of actions in the test**. Once all expectations have been set, a "wait" API is called that will **block execution of subsequent test code** until all expected conditions have been fulfilled or a timeout occurs.

So, how do we use it? 

1. Set up an "expectation" telling Xcode that it should start waiting.
2. When our asynchronous code returns we inform the test runner that all is well and no more waiting needs to occur.
3. Let Xcode know how long it should wait before failing.

Here is how we can use that technique in our existing test.

``` swift
func test_GET_ReturnsData() {
    let subject = URLSession.shared
    let url = URL(string: "https://masilotti.com")!
    let expectation = self.expectation(description: "Wait for \(url) to load.")
    var data: Data?

    subject.dataTask(with: url) { (theData, _, _) in
        data = theData
        expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
    XCTAssertNotNil(data)
}
```

Beautiful! With just three extra lines of code we can set up an asynchronous test in Swift with some XCTest helpers. Bonus: we didn't have to tick the run loop or play with semaphores.

## Async testing FTW! Right?

So we have a green test suite and everything seems to be in working order. But you might have noticed that this single test can take a while to run. Try changing the URL to point to a less reliable site. You will quickly notice that the time it takes to run your test suite quickly grows.

Now imagine you are following this approach to test many URL combinations. One for POSTing data, one to handle an error case, one to test when the user is logged out. The list goes on. Think of how long this will make your suite take.

Well, what's so bad about a slow test suite? Take it from the experts.

> Different people have different standards for the speed of unit tests and of their test suites. [David Heinemeier Hansson](http://david.heinemeierhansson.com/2014/slow-database-test-fallacy.html) is happy with a compile suite that takes a few seconds and a commit suite that takes a few minutes. [Gary Bernhardt](https://www.destroyallsoftware.com/blog/2014/tdd-straw-men-and-rhetoric) finds that unbearably slow, insisting on a compile suite of around 300ms and [Dan Bogart](http://dan.bodar.com/2012/02/28/crazy-fast-build-times-or-when-10-seconds-starts-to-make-you-nervous/) doesn't want his commit suite to be more than ten seconds - [Martin Fowler](http://martinfowler.com/bliki/UnitTest.html)

In my opinion the reason is even simpler. **The longer your test suite takes to run the less you will want to run it.** What's the point of putting all of this work into your tests when you only run them occasionally?

### What about stubbing the network?

The same holds true for stubbed out network requests. The `URLSession` API is inherently asynchronous. This means no matter how fast we get the "network" to return data each test still adds a nontrivial amount of time to our suite.

## Flatten that async

To keep our tests running fast let's completely flatten the code path. One thread, no asynchronous behavior, no network activity.

### Update `MockURLSession`

To do so we need to add two more variables to the `MockURLSession` we built when [testing the input to `URLSession`]({% post_url 2016-01-11-testing-nsurlsession-input %}#create-a-mock-for-tests).

``` swift
class MockURLSession: URLSessionProtocol {
    var nextData: Data?
    var nextError: Error?

    func dataTaskWithURL(_ url: URL, completion: DataTaskResult) -> URLSessionDataTaskProtocol { /* ... */ }

    // ... //
}
```

Now we can set what data and/or error is returned from the `dataTaskWithURL()` method. But wait, that method returns a data task, right? Correct, but look at the last parameter.

The completion handler would normally be called by the API when a real network request returns. We need to replicate this while we build our own mock. To do so, simply call the handler with our "next" variables before returning.

``` swift
class MockURLSession: URLSessionProtocol {
    private(set) var lastURL: URL?

    var nextData: Data?
    var nextError: Error?

    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = url
        completion(nextData, nil, nextError)
        return URLSession.shared.dataTask(with: url)
    }
}
```

We now have more control of what happens when creating the data task. As soon as our tests call into this method the completion handler will be executed (on the same thread, too).

### Testing returned data and error

To continue our testing of `HTTPClient` let's assert what happens when the network returns valid data.

1. Assign some dummy data to the "next" variable on the mock session.
2. Capture the returned data in `get()`'s completion block.
3. Assert that the two data are the same.

``` swift
class HTTPClientTests: XCTestCase {
    var session: MockURLSession!
    var subject: HTTPClient!
    let url = URL(string: "https://masilotti.com")!

    override func setUpWithError() throws {
        session = MockURLSession()
        subject = HTTPClient(session: session)
    }

    func test_GET_WithResponseData_ReturnsTheData() {
        let expectedData = "{}".data(using: .utf8)
        session.nextData = expectedData

        var actualData: Data?
        subject.get(url: url) { (data, _, _)  in
            actualData = data
        }

        XCTAssertEqual(actualData, expectedData)
    }
}
```

Continuing that pattern we can easily test the scenario where we encounter a network issue.

``` swift
func test_GET_WithANetworkError_ReturnsANetworkError() {
    session.nextError = NSError(domain: "error", code: 0, userInfo: nil)

    var error: Error?
    subject.get(url: url) { (_, _, networkError) -> Void in
        error = networkError
    }

    XCTAssertNotNil(error)
}
```

Not too bad, right? Now that we have some failing tests we can implement the bit of code to make them pass. We also need to create our own `ErrorType` to return when something goes wrong.

``` swift
enum HTTPError: Error {
    case network
}

class HTTPClient {
    // ... //

    func get(url: URL, completion: @escaping HTTPResult) {
        let task = session.dataTaskWithURL(url) { (data, _, error) -> Void in
            if let _ = error {
                completion(nil, HTTPError.network)
            } else {
                completion(data, nil)
            }
        }
        task.resume()
    }
}

```

## What's next?

You now have two different approaches to testing your networking layer. You can use XCTest's asynchronous extension to test a real HTTP request. Or you can stub out the network activity for a faster, synchronous test suite.

The third and final post on testing `URLSession` explores [stubbing network requests when UI Testing]({% post_url 2016-03-04-ui-testing-stub-network-data %}) for a more integration-style testing.
