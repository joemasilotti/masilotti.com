---
title: Clean up your Swift test suite with XCTUnwrap
date: 2021-01-21
description: Learn how to avoid force unwrapping optionals in your test suite without any trade-offs.
---

`XCTUnwrap` is a public XCTest helper that often gets overlooked. It was added in Xcode 11 and slipped under my radar until recently.

As you might have guessed, the helper unwraps optional values. It’s kind of like force unwrapping, but made specifically for your test suite. Here are a few advantages and reasons you should be using `XCTUnwrap` in your Swift tests.

### Raising errors vs. fatal errors

But first, a little background. In Swift you have a few ways to deal with errors. The most common way to raise one is with `throw`.

```swift
enum APIError: Error {
    case network, http, decoding, unknown
}

struct API {
    func getResource() throws {
        // ...
        if invalidJSON {
            throw APIError.decoding
        }
        // ...
    }
}
```

We can test that this method throws the decoding error with `XCTAssertThrowsError`. Note the error handling block, this is where we validate _which_ error was thrown.

```swift
func test_getResources_throwsADecodingError() throws {
    XCTAssertThrowsError(try API().getResource()) { error in
        XCTAssertEqual(error as? APIError, APIError.decoding)
    }
}
```

If `API` did _not_ throw an error this test would fail. The test suite would continue to run as expected. A **fatal error**, however, is quite different.

### Fatal errors

Consider the following (admittedly contrived) code.

```swift
struct App {
    func start() throws {
        if somethingReallyBadHappens {
            fatalError("Something terrible has occurred.")
        } else {
            // ...
        }
    }
}
```

Testing the `fatalError()` code path is actually impossible. If a fatal error is encountered the entire test suite grinds to a halt.

It’s similar to raising an uncaught exception Objective-C. There is no where for the error to go so it brings down the entire process. And because the test suite hangs off of the app, the test suite goes down with the app.

### Force unwrapping

Why does all of this matter? Well, as you may have guessed from this section's title, it relates to force unwrapping optionals.

Developers are warned to avoid force unwrapping in their codebase like the plague. However, the rules are a bit more lax when under test. Hell, I sometimes even *recommend* force unwrapping in your test suite!

But it comes with a big downside. Force unwrapping a `nil` is the equivalent to a fatal error. Said another way, **force unwrapping a `nil` completely stops your test suite**.

No more tests are run, the output is truncated, and you’re left with a big red line across your IDE.

## XCTUnwrap to the rescue

Now that we know the downsides of force unwrapping, how can we avoid it in our test suite? With `XCTUnwrap`, of course! Here’s how it’s used.

Assume we have a coordinator-like `App` that kicks off our application. It pushes a controller that displays the name of a customer.

```swift
class CustomerViewController: UIViewController {
    var name = ""

    // Display the name of the customer...
}

struct App {
    let navigationController = UINavigationController()

    func start() {
        let controller = CustomerViewController()
        controller.name = "Joe"
        navigationController.pushViewController(controller, animated: false)
    }
}
```

Here’s how I used to write a test for this.

```swift
func test_start_pushesJoesCustomerViewController() throws {
    let app = App()
    app.start()
    let firstViewController = app.navigationController.viewControllers.first
    let customerViewController = firstViewController as! CustomerViewController
    XCTAssertEqual(customerViewController.name, "Joe")
}
```

Which will pass! But what happens when we break something and we forgot to push a `CustomerViewController`?

```swift
func start() {
    let controller = UIViewController()
    navigationController.pushViewController(controller, animated: false)
}
```

We end up with a fatal error because we force unwrapped the controller type. Now our test suite grinds to a halt, errors out, and we have to manually dig in to the problem. Even worse, if this was on CI you’re stuck reading through the logs because the test runner never finished.

### Using XCTUnwrap to unwrap optionals

Now, here’s how I would write this test. Instead of force unwrapping we can use `XCTUnwrap` to ensure the type casting works as expected.

```swift
func test_start_pushesJoesCustomerViewController() throws {
    let app = App()
    app.start()
    let firstViewController = app.navigationController.viewControllers.first
    let customerController =
        try XCTUnwrap(firstViewController as? CustomerViewController)
    XCTAssertEqual(customerViewController.name, "Joe")
}
```

If our little gremlin happens again and we push the wrong view controller we will now get a nice test failure and the suite will continue on like usual.

> `XCTUnwrap failed: expected non-nil value of type "CustomerViewController"`

We could even add our own failure message if we desire, like the rest of the `XCT*` helpers.

## More applications of XCTUnwrap

I’m starting to see more and more opportunities to use `XCTUnwrap` in my Swift test suite. Early, explicit feedback is best. And this helper provides just that.

It also goes well with Swift TDD. Using the example above, a failing unwrap allows you to write the code to push the controller. Then you add another assertion to set the name. And on and on. Instead of the test suite falling over you get quick, tiny feedback loops of failing tests.

## Join the conversation

This post was inspired by a [conversation](https://twitter.com/joemasilotti/status/1350134472428068867) I had with [Alex Basson](https://twitter.com/boycats) and [Robert Atkins](https://twitter.com/ratkins) on Twitter (both Pivotal Labs folks). Thanks to both of you for challenging my way of thinking!

I'd love to hear what you think about this approach. Or any of my other posts. Feel free to [mention or DM me on Twitter](https://twitter.com/joemasilotti). I reply to everyone.
