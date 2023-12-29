---
title: Custom helpers in XCTest
date: 2015-09-21
description: How to extract XCTest helper methods and keep sane failure messages.
---

<p class="note"><strong>Update</strong>: Starting with Xcode 12, test failures automatically appear at the calling line!</p>

![Starting with Xcode 12, test failures automatically appear at the calling line!](/assets/images/xctest-helpers/helper-failure-xcode-12.png){:standalone .rounded-none}

---

As your test suite grows it's important to keep your code DRY. Or, [Don't Repeat Yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself). You wouldn't implement the same method three times in your production code, so why do it in your tests?

An easy way to maintain quality in your test suite is to share assertions between tests. This can be accomplished by extracting helper methods to run common assertions.

For example, in UI Testing waiting for elements to appear is quite verbose. I don't want to write this more than once if I can avoid it.

```swift
let element = app.buttons["Spike!"]
let existsPredicate = NSPredicate(format: "exists == true")
expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
waitForExpectations(timeout: 5, handler: nil)
```

Let's tease out a method that waits for an element to appear.

```swift
private func waitForElementToAppear(element: XCUIElement) {
    let existsPredicate = NSPredicate(format: "exists == true")
    expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
    waitForExpectations(timeout: 5, handler: nil)
}
```

Great! Now we can just call `waitForElementToAppear(app.cells["Joe"])` and our helper will take care of the rest. What happens when the test fails?

![Error message showing up in helper method, not calling line](/assets/images/xctest-helpers/helper-failure-incorrect.png){:standalone}

Oh, wait, that's not good. I want the failure message to be as close to the line of code *that I wrote* as possible.

Think about it as if you are writing a framework. Would you want to force your users to dig through the internal framework code just to see an error message? No, of course not. Let's move that message closer to the actual test.

```swift
private func waitForElementToAppear(element: XCUIElement,
                                    file: String = #file,
                                    line: UInt = #line) {
    let existsPredicate = NSPredicate(format: "exists == true")
    expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
    waitForExpectations(timeout: 5, handler: nil)
}
```

Here we are taking advantage of the manual failure override with `recordFailureWithDescription()`. This takes in a [failure message, file reference, line number, and a boolean](https://developer.apple.com/documentation/xctest/xctestcase/1496269-recordfailure).

> Note that this method has been deprecated; see the message above for newer versions of Xcode.

- *message*: the copy that the user will see when the test fails
- *file*: a reference to the file where the failure was originally recorded
- *line*: a reference to the line number where the failure was originally recorded
- *expected*: `true` for test failures and `false` for uncaught exceptions

The handler is called all the time and doesn't depened on whether the assertion failed or not. When the check fails the `error` parameter is populated, so we need to make sure it's present to fail our test.

The `file` and `line` parameters are where the magic happens. By specifying them as optional the caller is not obligated to pass anything in. And by defaulting them to the `#file` and `#line` macros we can capture those attributes at the source; where are our methods is being *called*. The Swift blog has an awesome post peeking into [how Apple built `assert()` in Swift](https://developer.apple.com/swift/blog/?id=15).

![Error message correctly showing up on calling line](/assets/images/xctest-helpers/helper-failure-correct.png){:standalone}

Ah, much better. Now we can add helper methods to our heart's content! We can continue passing these parameters down the chain and create a highly abstracted testing framework built on XCTest.
