---
title: Waiting in XCTest
date: 2017-01-25
description: Waiting is hard, and waiting in Xcode is no exception. Learn a new approach with classes introduced in Xcode.
---

You can now wait for elements in UI Testing with a single line.

```swift
let app = XCUIApplication()
let label = app.labels["Wait for me..."]
XCTAssert(label.waitForExistence(timeout: 5)))
```

Read on for how to do the same in older versions of Xcode.

---

Waiting is hard, and waiting in Xcode is no exception. Even choosing from the myriad of options Xcode and XCTest provide can be difficult. Read on to learn an easy and straightforward approach to waiting for expectations with new classes introduced in Xcode.

![The waiting is the hardest part](/assets/images/xctest-waiting/waiting.png){:standalone}

## Before Xcode 8.3

Xcode 7 introduced a slew of new methods to help test asynchronous code, namely, `waitForExpectations(timeout: handler:)`. This method can be used to, well, wait for expectations.

An `XCTestExpectation` is an XCTest class that continuously evaluates an expression until it is fulfilled or the timeout is reached. These can be used to wait for animations to finish, elements to appear, or even key values to change via KVO.

Here's a brief example from my [UI Testing Cheat Sheet]({% post_url 2015-09-14-ui-testing-cheat-sheet %}) post.

```swift
func waitForElementToAppear(_ element: XCUIElement) {
    let existsPredicate = NSPredicate(format: "exists == true")
    expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
    waitForExpectations(timeout: 5, handler: nil)
}
```

This code is used in a UI Test to wait for a specific element to appear on the screen. You pass in the `XCUIElement` and the helper tries to find the element for five seconds.

The `waitForExpectations` helper is great, but it comes with one caveat. It raises an exception and fails the test if the timeout is reached. This limits its functionality to cases where we *absolutely know* the expectations will be met.

### The Expectation Completion Handler

Take note that I've passed `nil` for the `handler:` parameter in the code sample.

> **handler**: An optional `XCWaitCompletionHandler` block to invoke when all expectations have been fulfilled or when the wait timeout is triggered. (Timeout is always treated as a test failure.)

And that handler is a simple alias to wrap an optional error in a block.

> A block to be called when a call to `waitForExpectations(timeout:handler:` has all of its expectations fulfilled, or times out.
>
> `typealias XCWaitCompletionHandler = (Error?) -> Void`

At first glance this definition is exciting, it is easy to infer that the error will contain all sorts of useful information. However, in practice, that is not the case. Very rarely has it been anything more than a generic `Error` with no (localized) description. 😞

Lucky for us, Xcode 8.3 has added a few new classes and helpers to make understanding the failure reason a little bit easier to understand.

> **The remainder of this post references new functionality introduced in Xcode 8.3 Beta.**

## Enter `XCTestWaiter`

> Manages waiting - pausing the current execution context - for an array `XCTestExpectations`. Waiters can be used with or without a delegate to respond to events such as completion, timeout, or invalid  expectation fulfillment. `XCTestCase` conforms to the delegate protocol and will automatically report timeouts and other unexpected events as test failures.
>
> Waiters can be used without a delegate or any association with a test case instance. This allows test support libraries to provide convenience methods for waiting without having to pass test cases through those APIs.

At first glance `XCTestWaiter` is simply a new approach to waiting for `XCTestExpectation`s to fulfill. However, there are a few gems hidden beneath the surface.

First, let's convert the "old" sample to use the new class.

```swift
func waitForElementToAppear(_ element: XCUIElement) -> Bool {
    let predicate = NSPredicate(format: "exists == true")
    let expectation = expectation(for: predicate, evaluatedWith: element,
                                  handler: nil)

    let result = XCTWaiter().wait(for: [expectation], timeout: 5)
    return result == .completed
}
```

`wait(for:timeout:)` returns an `XCTestWaiterResult`, an enum representing the result of the test. It can be one of four possible values: `completed`, `timedOut`, `incorrectOrder`, or `invertedFulfillment`. Only the first, `completed`, indicates that the element was successfully found within the allotted timeout.

A big advantage of this approach is that the test suite reads as a synchronous flow. There is no callback block or completion handler. The helper method simply returns a boolean indicating if the element appeared or not.

### Unfulfilled Expectations Do Not Automatically Fail 😅

In my opinion this is the biggest improvement to the framework. You are now completely in control of when and how to fail your tests if an expectation fails to fulfill. This enables waiting for optional elements, like a login screen or a location services authorization dialog.

You can also break out each type of `XCTestWaiterResult` and fail them with individual error messages. For example, `.timedOut` can mention how long the timeout was while `incorrectOrder` can use `fulfilledExpectations` to note which succeeded and which we are still waiting on.

### Multiple Expectations

More than one `XCTestExpectation` can be passed to the waiter which can be used in two different scenarios.

1. *Any* of the expectations need to be fulfilled - as soon as one is met the waiter stops waiting
2. *All* of the expectations need to be fulfilled - the waiter continues to wait until all are fulfilled

To indicate that *all* of the expectations matter, simply call `wait(for:timeout:enforceOrder:)`. The last parameter will indicate to the framework if the order of fulfillment also matters.

### New  `XCTestExpectation` Subclasses

Along with the new waiter class, `XCTestExpectations` was subclassed to make specific expectations a little easier to write. I suggest using these whenever possible, readability goes a long way in writing a maintainable test suite.

#### `XCTPredicateExpectation`

```swift
func waitForElementToAppear(_ element: XCUIElement) -> Bool {
    let predicate = NSPredicate(format: "exists == true")
    let expectation = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                object: element)

    let result = XCTWaiter().wait(for: [expectation], timeout: 5)
    return result == .completed
}
```

#### `XCTKVOExpectation`

```swift
func waitForElementToAppear(_ element: XCUIElement) -> Bool {
    let expectation = XCTKVOExpectation(keyPath: "exists", object: element,
                                        expectedValue: true)

    let result = XCTWaiter().wait(for: [expectation], timeout: 5)
    return result == .completed
}
```

#### `XCTNSNotificationExpectation`

~~I can't seem to get this one to work 😟. If anyone has success with this subclass please let me know in the comments.~~

```swift
func waitForNotificationNamed(_ notificationName: String) -> Bool {
    let expectation = XCTNSNotificationExpectation(name: notificationName)
    let result = XCTWaiter().wait(for: [expectation], timeout: 5)
    return result == .completed
}
```

Thanks for the help, [Brian](https://twitter.com/aikoniv)!

## Xcode 8.4 and Beyond

It's comforting to see Apple reinvesting in their testing framework; there hasn't been much activity to XCTest since its revamp in Xcode 7. I'm looking forward to trying out anything new that comes with the next release!
