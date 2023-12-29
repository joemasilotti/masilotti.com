---
title: Dynamically verified Swift mocks
date: 2020-12-31
description: How to verify which messages a Swift mock receives with less boilerplate and no third-party code.
---

December has been a month of discovery for me. I’ve been exploring alternative approaches to different testing techniques in Swift.

Everything kicked off with a little experiment on [how to test the UI without UI Testing]({% post_url 2020-12-03-testing-ui-without-ui-testing %}). This got me thinking, what if we continue to bring more code "in house?" Fewer dependencies and more bespoke solutions.

That lead to [rolling your own dependency injection in Swift]({% post_url 2020-12-17-swift-dependency-injection %}). This explores a technique I’ve been using for a while but hadn’t yet talked much about.

Last week I wrote about an alternative to Swift mocks, [inheritance instead of protocols]({% post_url 2020-12-24-swift-mocks-without-protocols %}). There’s a few trade-offs but its a technique I’m excited to use more in the new year.

To wrap up the month I’ll be diving into an alternative approach to recording function calls on Swift mocks. We’ll take advantage of a Swift literal expression to let the language do some of our heavy lifting.

## Verifying function calls

This post, as most on Masilotti.com, follows the approach I take in [Better unit testing with Swift]({% post_url 2020-03-31-better-swift-unit-testing %}). Here’s a quick summary/refresher.

### All dependencies are protocols

First, all dependencies are protocols. Objects do not know about concrete types. To simplify for this example we will verify sent messages to a delegate.

Here we have a `Visitor` which loads a URL in a web view. After kicking off the request it is responsible for letting the delegate know when the visit starts and finishes.

```swift
protocol VisitDelegate: class {
    func visitDidStart()
    func visitDidFinish()
}

class Visitor: NSObject {
    private weak var delegate: VisitDelegate?
    private let webView = WKWebView()

    init(delegate: VisitDelegate) {
        self.delegate = delegate
        super.init()
        webView.navigationDelegate = self
    }

    func visit(_ url: URL) {
        webView.load(URLRequest(url: url))
        delegate?.visitDidStart()
    }
}

extension Visitor: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.visitDidFinish()
    }
}
```

### Mocks implement the protocol

Our test doubles are mocks - they track which messages are sent to be verified later.

```swift
class MockVisitDelegate: VisitDelegate {
    private(set) var visitDidStart_wasCalled = false
    private(set) var visitDidFinish_wasCalled = false

    func visitDidStart() {
        visitDidStart_wasCalled = true
    }

    func visitDidFinish() {
        visitDidFinish_wasCalled = true
    }
}
```

Which we use to verify in our test.

```swift
class Tests: XCTestCase {
    // Needs to "live" in between tests otherwise XCTest crashes.
    let navigation = WKNavigation()

    func test_visit_tellsTheDelegate() {
        let delegate = MockVisitDelegate()
        let visitor = Visitor(delegate: delegate)
        visitor.visit(URL(string: "https://example.com/foo")!)
        XCTAssert(delegate.visitDidStart_wasCalled)
    }

    func test_webViewDidFinish_tellsTheDelegate() {
        let delegate = MockVisitDelegate()
        let visitor = Visitor(delegate: delegate)
        visitor.webView(WKWebView(), didFinish: navigation)
        XCTAssert(delegate.visitDidFinish_wasCalled)
    }
}
```

This approach works really well for tiny objects. But as it grows the boilerplate quickly adds up. Every new function requires a new property on the mock.

## Dynamically recorded function calls
Instead of keeping track of each function call manually, we can store them somewhere and query later.

```swift
class MockVisitDelegate: VisitDelegate {
    private(set) var methodsCalled: Set<String> = []

    func didCall(_ function: String) -> Bool {
        methodsCalled.contains(function)
    }

    func visitDidStart() {
        record("visitDidStart()")
    }

    func visitDidFinish() {
        record("visitDidFinish()")
    }

    private func record(_ function: String) {
        methodsCalled.insert(function)
    }
}
```

This leaves us with a new interface to query called methods.

```swift
XCTAssert(delegate.didCall("visitDidFinish()")
```

While an improvement, this is ripe for typos. Let’s replace the magic strings in the mock with `#function`.

> `#function` is a [literal expression](https://docs.swift.org/swift-book/ReferenceManual/Expressions.html#ID390) returning the name of the declaration in which it appears.

```swift
class MockVisitDelegate: VisitDelegate {
    // ...

    func visitDidStart() {
        record()
    }

    func visitDidFinish() {
        record()
    }

    private func record(_ function: String = #function) {
        methodsCalled.insert(function)
    }
}
```

This works because the `function` parameter is defaulted from the caller. So invoking `record()` from inside `visitDidStart` passes `"visitDidStart()"` down the chain.

Our tests remain the same.

### Abstracting to shared behavior

We cut down on a fair amount of boilerplate but I think we can do even better. Let’s pull the shared behavior into a protocol to reuse across the test suite.

```swift
protocol Mock: class {
    var methodsCalled: Set<String> { get set }
}

extension Mock {
    func didCall(_ function: String) -> Bool {
        methodsCalled.contains(function)
    }

    func record(_ function: String = #function) {
        methodsCalled.insert(function)
    }
}
```

Now our mock only needs to add the `Mock` conformance and the `methodsCalled` property. It now looks like this, almost 10 lines lighter!

```swift
class MockVisitDelegate: VisitDelegate, Mock {
    var methodsCalled: Set<String> = []

    func visitDidStart() {
        record()
    }

    func visitDidFinish() {
        record()
    }
}
```

## Pros and cons

This technique works really well when all you care about is which function was called. You get a clean, concise, infinitely extendable API without relying on a third party library.

However, you lose type safety and introduce magic strings. If you ever rename `visitDidStart` to `visitStarted` you can’t rely on the compiler to fix your test assertions.

The approach also doesn’t handle parameter verification. What if `visitDidStart` also cares about the path of the URL? Or you need to make two calls to the same function with different arguments?

I’m planning to explore these shortcomings in a future post. Stay tuned!

How do you verify your mocks? Do you use a technique similar to this or a third-party library? I’d love to hear what you think on Twitter!

## Inspiration for this post

P.S. This post was inspired by some code in Basecamp’s new library, [Turbo](https://github.com/hotwired/turbo-ios). This framework enables small teams to build high-fidelity hybrid apps with native navigation in a single shared web view.

I’ve built a few of these in the past and they work (and scale!) really well. If you’d like to give it a try don’t hesitate to [send me an email](mailto:joe@masilotti.com). I’d love to work together.
