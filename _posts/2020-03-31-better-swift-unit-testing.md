---
title: Better unit testing with Swift
date: 2020-03-31
description: Ideas and best practices for real world Swift testing, including protocols, dependency injection, and Equatable.
---

> This article was updated on March 31, 2020. It includes feedback from a live session I hosted on testing in Swift. [Email me](mailto:joe@masilotti.com) if you want to join the next session!

I'm a big fan of third party testing frameworks. My first foray into testing was with [Cedar](https://github.com/pivotal/cedar) and eventually [Rspec](http://rspec.info). Now that more of my work has moved to Swift I've been enjoying [Quick](https://github.com/quick/quick) and [Nimble](https://github.com/quick/nimble).

With the release of Swift 2.0 and Xcode 7 I though it was a great time to try writing my unit tests using only Apple's XCTest framework. That's right, no dependencies, no [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development), and no matchers.

Here are some concepts that I've picked up over the past couple of months of "real-world" unit testing in Swift. I wish I knew these from the beginning, but hopefully they can help spark some light with seasoned Swift testers too.

## Swift unit testing mindset

Before diving into details, let's highlight the general ideas when writing a Swift unit test.

1. Everything is a protocol. Classes do not know about concrete types.
2. Mocks implement protocols to keep track of which functions are called with what.
3. Static dependencies are `let` variables and injected at initialization time.
4. Mocks are `Equatable`, enabling use of `XCTAssertEqual()` under test.

## Inject static dependencies

The most important of these "rules" is to inject your dependencies. Without a solid approach to DI your tests can become very difficult to write.

> To me, **dependency injection** means an object doesn't create its own instance variables. The objects are "given" to the class from somewhere else.

For example, let's look at a service layer object, `BoardGameService`. Its role is to retrieve data from an API and pass it along to a parser. Note that I'm assuming everything happens synchronously and cannot fail.

```swift
struct BoardGameService {
    let api = BoardGameAPI()
    let parser = BoardGameParser()

    func boardGame(id: UInt) -> BoardGame {
        let json = api.json("/board-games/\(id)")
        return parser.parse(json)
    }
}
```
How can we test that the correct path was passed to the API? There is no way to assert which objects were passed through because the service is creating the object itself. The dependency is *not* being injected.

Well, let's inject it!

```swift
struct BoardGameService {
    let api: BoardGameAPI

    init(api: BoardGameAPI) {
        self.api = api
    }

    // ...
}
```

Now under test we can pass in our own `BoardGameAPI` instance.

```swift
class BoardGameServiceTests: XCTestCase {
    func test_GettingABoardGame_BuildsThePath() {
        let api = BoardGameAPI()
        let subject = BoardGameService(api: api)

        subject.boardGame(42)

        // assert path
    }
}
```

Great, now we can give the object under test, `subject`, any instance of `BoardGameAPI` that we want. It could be a "testable" subclass, a mock, or even a spied instance.

The best approach here is to make `BoardGameAPI` conform to a protocol, so we can inject a mock instance to run assertions on.

## Make dependencies protocols

Let's use a protocol to get around creating messy subclasses of concrete objects under test. In this scenario, we want `BoardGameAPI` to conform to something, say `API`.

```swift
protocol API {
    func json(path: String) -> JSON
}

struct BoardGameAPI: API {
    func json(path: String) -> JSON {
        // ...
    }
}
```

Now that the dependency is straightened out, we need to make the consumer think in terms of protocols, not concrete classes.

```swift
struct BoardGameService {
    let api: API

    init(api: API) {
        self.api = api
    }

    // ...
}
```

Beautiful. Now under test we create one more object to keep track of which methods get called with what. You only need to add this class to your test bundle.

```swift
struct MockAPI: API {
    var lastPath: String?

    func json(path: String) -> JSON {
        lastPath = path
        return JSON()
    }
}
```

Note the instance variable, `lastPath`, which gets set upon calling `json()`. We use this property to assert that the function was called with the correct parameter.

```swift
struct BoardGameServiceTests: XCTestCase {
    func test_GettingABoardGame_BuildsThePath() {
        let api = MockAPI()
        let subject = BoardGameService(api: api)

        subject.boardGame(42)

        XCTAssertEqual(api.lastPath, "/board-games/42")
    }
}
```

To test the interaction with the `BoardGameParser` we follow the same path. First create a `Parser` protocol and make `BoardGameParser` conform to it. Then add `lastJSON` to our new `MockParser`. It may start to feel tedious having to create *three* objects for every class. But in the long run you are given fine-grain control over how your mocks and tests work.

## Set default initialization parameters

One catch with this approach is that every time you create a `BoardGameService` you will need to pass in the dependencies. Under test this is fine (actually, preferable) but in production code it quickly gets annoying.

To remedy this we can use Swift's [default parameter values](https://developer.apple.com/library/watchos/documentation/Swift/Conceptual/Swift_Programming_Language/Functions.html#//apple_ref/doc/uid/TP40014097-CH10-ID169) for the initializer. This means that the object knows what it needs unless it's told otherwise. Set default values for all *static* dependencies, think anything other than a delegate or model object.

```swift
struct BoardGameService {
    let api: API
    let parser: Parser

    init(api: API = BoardGameAPI(), parser: Parser = BoardGameParser()) {
        self.api = api
        self.parser = parser
    }

    // ...
}

```

Now that all our classes are being injected protocols, let's move on to the actual tests. What are some best practices with writing Swift unit tests?

## Structure and name tests with preconditions, the stimulus, then assertions

When naming tests I make sure to follow one rule.

> When I look at this test in six months I should understand what it's actually testing.

What does that mean in practice? Well let's break down the `BoardGameService` test example.

```swift
struct BoardGameServiceTests: XCTestCase { // test class Name
    func test_GettingABoardGame_BuildsThePath() { // test case
        let api = MockAPI()
        let subject = BoardGameService(api: api) // preconditions

        subject.boardGame(42) // stimulus

        XCTAssertEqual(api.lastPath, "/board-games/42") // assertion
    }
}
```

The **test class name** matches the name of the object under test. Simple.

I like to name my **test case** so it is obvious to see what method is being called and what the assertion is. In this example `GettingABoardGame` correlates to calling `boardGame()` on the service. I like to name these to match the behavior, not necessarily the function name.  The last part introduces what the assertions are testing. Here, we want to make sure that the path that is sent to the API is correct, so `BuildsThePath`.

The **preconditions** are where the test setup occurs. This can be injecting dependencies, initializing known values, or even other function calls. The idea is get the subject in a known state for the stimulus. I try to restrict my use of the `setUp()` method of XCTest for object instantiation.

Next, the **stimulus** is where the actual "work" gets done. This is where you call the actual function on the object under test.

Finally, you list out your **assertions**. By keeping these together and at the end it makes it easy to skim the tests and see what is being tested and where.

As your application's test suite grows it can becomes harder to read and understand the tests you wrote. By constraining them to a shared format and cadence you are making it easier make changes in the future.

## Make value types `Equatable`

The last part of the Swift testing puzzle is making sure you can run valid assertions on your mocks and fakes.

XCTest provides a number of different assertions dealing with all sorts of primitive types. But the most valuable one, or at least the one I use most, is `XCTAssertEqual()`.

> `XCTAssertEqual(expression1, expression2)` - causes a failure when `expression1` is not equal to `expression2`

When using this to compare Swift objects there is one minor caveat. The two instances you are comparing must conform to the `Equatable` protocol.

> [Apple](https://developer.apple.com/videos/wwdc/2015/?id=414) and [others](https://www.andrewcbancroft.com/2015/07/01/every-swift-value-type-should-be-equatable/) recommend that every Swift value type should be equatable.

Conforming to `Equatable` is easy, you just have to [implement the `==` function](http://nshipster.com/swift-comparison-protocols/#equatable) and perform the necessary equality checks. Let's use the `BoardGame` model from earlier as an example. Note that the function is defined *outside* of the class and extension.

```swift
protocol Game {
    var name: String { get }
    var maximumPlayers: UInt { get }
}

struct BoardGame: Game {
    let name: String
    let maximumPlayers: UInt

    init(name: String, maximumPlayers: UInt) {
        self.name = name
        self.maximumPlayers = maximumPlayers
    }
}

extension BoardGame: Equatable { }

func ==(lhs: BoardGame, rhs: BoardGame) -> Bool {
    return lhs.name == rhs.name && lhs.maximumPlayers == rhs.maximumPlayers
}
```

Under test we can now use `XCTAssertEqual()` to ensure our mocks were called with the correct parameters.

```swift
struct BoardGameParserTests: XCTestCase {
    func test_ParsingValidJSON_ReturnsABoardGame() {
        let subject = BoardGameParser()
        let json = ["name": "Carcassonne", "maximumPlayers": 5]
        let expectedBoardGame = BoardGame(name: "Carcassonne", maximumPlayers: 5)

        let actualBoardGame = subject.parse(json)

        XCTAssertEqual(actualBoardGame, expectedBoardGame)
    }
}
```

Oh, and if you're looking for [great two player board games]({% post_url 2020-03-15-great-two-player-board-games %}) I've got you covered!

## Recap: *IDEPEM*!

To help remember the Swift Unit Testing Mindset, just think *IDEPEM*.

* **I**nject
* **D**ependencies,
* **E**verthing's a
* **P**rotocol,
* **E**quatable
* **M**ocks

Remember, you use the Xcode **IDE** and [generate .**PEM** files](https://docs.fastlane.tools/actions/pem/) for push notifications!

## Bonus: Custom XCTest helpers

An easy way to maintain quality in your test suite is to share assertions between tests. This can be accomplished by extracting helper methods to run common assertions.

Learn how to [extract common test behavior into helper methods]({% post_url 2015-09-21-xctest-helpers %}) while keeping those pesky failure messages on the right line.
