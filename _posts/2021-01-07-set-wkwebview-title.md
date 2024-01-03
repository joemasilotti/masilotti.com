---
title: How to set WKWebView's title under test
date: 2021-01-07
description: Learn how to "set" a computed property by taking advantage of the internals of WKWebView.
---

I ran into an interesting problem working with the [Turbo framework](https://github.com/hotwired/turbo-ios) the other day. I was writing a test that depended on `WKWebView`’s title but couldn’t figure out how to set it.

Title is a read-only, computed property, so there’s no way to set it directly. Even subclassing can’t overwrite it. I ended up with a small snippet that loads HTML directly into the web view. This then propagates the title to the property which we can use for the test.

## Load the HTML

Loading HTML into a web view is built in and straightforward enough. The internals of `WKWebView` will automatically set the title property to whatever the HTML’s title is.

```swift
let webView = WKWebView()
let html =
  """
  <html>
    <head>
      <title>Our title</title>
    </head>
  </html>
  """
webView.loadHTMLString(html, baseURL: nil)
```

But the title isn’t set right away, it happens asynchronously.

```swift
print(webView.title) // Prints "", an empty string!
```

## Waiting for the page to load

We can use XCTest expectations to wait for the title to be set. The web view’s delegate will tell us when the "page" loads (really just our HTML).

Fulfilling the expectation in the delegate callback ensures we don’t have to keep checking the web view’s title to fulfill the expectation.

```swift
class Tests: XCTestCase {
    var webViewExpectation: XCTestExpectation!

    func test_setTheWebViewTitle() throws {
        let webView = WKWebView()
        let html = "<html><head><title>Our title</title></head></html>"
        webView.navigationDelegate = self

        webViewExpectation = expectation(description: "")
        webView.loadHTMLString(html, baseURL: nil)
        wait(for: [webViewExpectation], timeout: 1)

        XCTAssertEqual(webView.title, "Our title")
    }
}

extension Tests: WKNavigationDelegate {
      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewExpectation.fulfill()
    }
}
```

The 1 second timeout is very generous, this test runs in about 0.1 seconds on my machine.

## Trade-offs

One downside to this approach is that if the web view had a navigation delegate it is no longer set. We can fix that by keeping a reference to the delegate and re-assinging after the callback completes.

Also, this test is now asynchronous. Even though it might only take 0.1 seconds to run, if you have 100 of these it might add up.

## Refactoring time!

I’ve pulled this snippet into a helper to make it easier to work with. Now I can set the title with a single line of code from inside a test.

```swift
class Tests: XCTestCase {
    func test_settingTheWebViewTitle() throws {
        let webView = WKWebView()
        webView.setTitle("A title!")
        XCTAssertEqual(webView.title, "A title!")
    }
}
```

Here’s how it looks, including the delegate "resetting" mentioned above.

```swift
extension XCTestCase {
    func setTitle(_ title: String, into webView: WKWebView) {
        let delegate = webView.navigationDelegate

        let navigationExpectation = expectation(description: "Wait for web view to finish loading the HTML string.")
        let navigationDelegate = NavigationDelegate(expectation: navigationExpectation)
        webView.navigationDelegate = navigationDelegate

        let html = htmlString(titled: title)
        webView.loadHTMLString(html, baseURL: nil)
        wait(for: [navigationExpectation], timeout: 1)

        webView.navigationDelegate = delegate
    }

    private func htmlString(titled title: String) -> String {
        """
        <html>
            <head>
                <title>\(title)</title>
            </head>
        </html>
        """
    }
}

private class NavigationDelegate: NSObject, WKNavigationDelegate {
    private let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        expectation.fulfill()
    }
}
```

## Alternatively, with KVO

`WKWebView`'s title is KVO-compliant, which means we can use `XCTKVOExpectation` to reduce some of our boilerplate.

```swift
class Tests: XCTestCase {
    func test_settingTheWebViewTitle() throws {
        let webView = WKWebView()
        let html = "<html><head><title>Our title</title></head></html>"
        webView.loadHTMLString(html, baseURL: nil)
        let expectation = keyValueObservingExpectation(for: webView, keyPath: "title") { (_, change) -> Bool in
            change["new"] as? String == "Our title"
        }
        wait(for: [expectation], timeout: 1)
    }
}
```

What about you, how would you test this? I’d love to [hear what you think on Twitter](https://twitter.com/joemasilotti)!
