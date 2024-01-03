---
title: XCTest tips and tricks that can level up your Swift testing
date: 2021-02-04
description: 10+ of my favorite techniques that I've picked up over the past few years of testing Swift code.
---

XCTest has a lot of tricks up its sleeve. But some of the really good stuff is buried behind macros or lacking adequate documentation. Here’s some of my favorite XCTest tips and tricks that I’ve picked up over the past few years testing Swift code.

### 1. Use `XCTUnwrap` instead of force wrapping optionals

Force unwrapping a `nil` will cause the test suite to completely crash, meaning no output or reporting. `XCTUnwrap` provides a nice failure message and fails the test.

```swift
// Don't do this! If leftBarButton is nil the test will CRASH.
let button = controller.navigationItem.leftBarButtonItem!
XCTAssertEqual(button.title, "Cancel")
```

```swift
// If leftBarButton is nil the test will fail.
let button = try XCTUnwrap(controller.navigationItem.leftBarButtonItem)
XCTAssertEqual(button.title, "Cancel")
```

More examples can be found in a recent article on [how to clean up your Swift test suite with XCTUnwrap]({% post_url 2021-01-21-xctunwrap %}).

### 2. Set `continueAfterFailure` to `false`

If you have multiple assertions in a test they might increase in specificity. The first asserts the size of the array and the second assets the last element. You don't want to run the second if the first fails, it's just noise.

```swift
class TestCase: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_pushingAnElementOnTheStack() throws {
        let stack = CustomStack(elements: [42])
        stack.push(9001)
        XCTAssertEqual(stack.count, 2)
        XCTAssertEqual(stack.topOfStack, 9001)
    }
}
```

### 3. Use KVO observing to test asynchronous expectations

Use [`XCTKVOExpectation`](https://developer.apple.com/documentation/xctest/xctkvoexpectation) to assert KVO-compliant properties on your subject under test.

```swift
let expectation = keyValueObservingExpectation(for: subject, keyPath: "property", expectedValue: value)
wait(for: [expectation], timeout: 1)
```

If your mock is an `NSObject` subclass you can also use this to wait for method calls without ticking the run loop! (Blog post coming soon.)

### 4. Assert types with `XCTAssert` and `is`

This technique is helpful when you only care about the type and not a particular instance.

```swift
XCTAssert(controller.presentedViewController is CustomViewController)
```

Keep in mind that the failure message isn’t super helpful. Brian Croom, Xcode Testing Technologies at Apple, [recommends adding a custom description](https://twitter.com/aikoniv/status/1356776234923954177?s=20).

### 5. Keep `XCTAssertEqual` parameter order consistent

The [documentation](https://developer.apple.com/documentation/xctest/xctassertequal) doesn't indicate if the expected or actual value should be first. Pick one and stick with it to make it obvious which is which for any test. Personally, I put the actual value first so all the constants end up at the end.

```swift
XCTAssertEqual(array.count, 2)
XCTAssertEqual(user.name, "Joe")
```

### 6. Extract helpers judiciously

If I need 3 or more lines of code to "do something" I extract it to a helper. This includes test setup, the action, and/or the assertion(s).

`XCTestCase` is a class so you can add any functions you’d like. Make sure your helpers don’t start with `test` otherwise they will be executed as a test.

If you are on Xcode 11 defining the function with `#filepath` and `#line` will pass along test failures to the caller. Xcode 12 does this for us automatically.

### 7. Add test extensions to reduce noise

> Thanks to [Lukas Schmidt](https://twitter.com/lightsprint09) for this tip!

Add extensions to your test target to clean up your call site and make your tests easier to read. Now your tests only have to specify what they care about.

```swift
// App/Models/User.swift
struct User {
    let firstName: String
    let lastName: String
}

// Test/Support/Helpers/User.swift
extension User {
    static func build(firstName: String = "Joe", lastName: String = "Masilotti") -> Self {
        Self(firstName: firstName, lastName: lastName)
    }
}

// Test/
let user = User.build()
let father = User.build(firstName: "John")
let friend = User.build(lastName: "Sussman")
```

### 8. Conform to `Equatable` to combine assertions

> Another shoutout to [Lukas Schmidt](https://twitter.com/lightsprint09) for this tip!

Making your models equatable enables you to test them as a whole, without writing an assertion for each property.

```swift
struct BoardGame {
    let name: String
    let players: UInt
}

extension BoardGame: Equatable {
    func ==(lhs: BoardGame, rhs: BoardGame) -> Bool {
        return lhs.name == rhs.name && lhs.players == rhs.players
    }
}

struct BoardGameParserTests: XCTestCase {
    func test_parsingValidJSON_returnsABoardGame() {
        let json = ["name": "Carcassonne", "players": 5]
        let boardGame = BoardGameParser.parse(json)

        // Instead of...
        XCTAssertEqual(boardGame.name, "Carcassonne")
        XCTAssertEqual(boardGame.players, 5)

        // combine them into one assertion.
        XCTAssertEqual(boardGame, BoardGame(name: "Carcassonne", players: 5))
    }
}
```

More examples and tips on `Equatable` can be found in [Better unit testing with Swift]({% post_url 2020-03-31-better-swift-unit-testing %}).

### 9. Always make your tests throw

> Thanks to [Sascha Gordner](https://twitter.com/forceunwrap) for this tip!

```swift
func test_withdrawingMoney() throws {
    let account = BankAccount(balance: 100)
    try account.withdraw(200)
    // ...
}
```

Adding `throws` to the end of the test captures any raised exceptions and lets you use `try` without `?` or `!` throughout the test. There’s also zero downside to adding it for every test, even if you don’t expect anything to raise an error.

### 10. Use protocols and mock extensively

> Thanks to  [Dominik Hauser](https://twitter.com/dasdom)  for this tip!

* Everything is a protocol. Classes do not know about concrete types.
* Mocks implement protocols to keep track of which functions are called with what.
* Static dependencies are `let` variables and injected at initialization time.
* Mocks are `Equatable`, enabling use of `XCTAssertEqual()` under test.

I’ve built my entire testing strategy around this technique.  For a complete rundown, make sure to read [Better unit testing with Swift]({% post_url 2020-03-31-better-swift-unit-testing %}).

### 11. Use `XCTAssertIdentical` in Xcode 12.5

From the recent Xcode 12.5 Beta release notes:

> XCTest will include `XCTAssertIdentical` and `XCTAssertNotIdentical` APIs to assert whether two object instances are identical (the same instance) and are stricter than `XCTAssertEqual` by using the `===` operator instead of `==` in Swift.

## Which `XCTest` techniques do you use?

Did you pick up any new techniques? Do you have a juicy one that I missed? [Mention or DM me on Twitter](https://twitter.com/joemasilotti) and I'll add your tip to the article!
