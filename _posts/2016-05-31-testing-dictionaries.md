---
title: Testing Dictionaries with Swift and XCTest
date: 2016-05-31
description: A type-safe approach to testing dictionaries in Swift with clean failure messages.
---

Dictionaries are the ultimate data courier. They can encapsulate different types of information to pass around your codebase. However, their very nature of dynamism makes them tricky to test in Swift. With a few rules, you can easily create robust, complete, and statically typed XCTest test cases for dictionaries.

To explain how I go about testing dictionaries, we will walk through a simple example: generating JSON from a model object. Yes, there are many libraries/posts on this but I will concentrate my efforts on *testing* the output, not generating it.

## The test subject: `BoardGame().toJSON()`

[I like board games]({% post_url 2020-03-15-great-two-player-board-games %}). Like, [a lot]({% post_url 2020-04-23-play-board-games-online %}). They also happen to translate well to data models. Board games hava string values, number values, and even nested attributes. For this post we will keep the modeling simple and use the following representation.

```swift
struct BoardGame {
    let name: String
    let type: String
    let maxPlayers: Int
}
```

Nice and simple, just a few properties. The function we are interested in, `toJSON()`, is just as straightforward.

```swift
func toJSON() -> Any {
    [
        "name": name, 
        "type": type, 
        "max-players": maxPlayers
    ]
}
```

Let's create the test case, now that we have our data model (and function implemented).

##  The "simple" test

The `toJSON()` function returns a few basic `String` and `Int` keys and values. Let's write a quick test to verify that they were all set correctly.

```swift
class BoardGameTests: XCTestCase {
    func test_toJSON() {
        let wingspan = BoardGame(name: "Wingspan", type: "Strategy", maxPlayers: 5)

        XCTAssertEqual(game.toJSON(), [
            "name": "Wingspan",
            "type": "Strategy",
            "max-players": 5
        ])
    }
}
```

```
Swift Compiler Error:
  Value of protocol type 'Any' cannot conform to 'Equatable'; only struct/enum/class types can conform to protocols
```

Oh no! Swift doesn't know how to compare our dictionary to the `Any` return type of the function. And we can't cast value to `[String: String]` since we have both `String` and `Int` values.

So, what do we do?

## Enter optional chaining

Swift is pretty fussy when it comes to types. It starts pouting if it doesn't know *exactly* what you are tying to compare. To give our favorite language a hand, we can take advantage of a technique called "optional chaining".

With this approach, we give hints to the compiler as to what type we *expect* a value to be. The call will return `nil` if the type is different. So, enough theory, here it is in practice.

```swift
func test_toJSON() {
    let wingspan = BoardGame(name: "Wingspan", type: "Strategy", maxPlayers: 5)
    let json = wingspan.toJSON() // 1
    let jsonDictionary = json as? [String: AnyObject] // 2
    XCTAssertEqual(jsonDictionary?["name"] as? String, "Wingspan") // 3
}
```

So, a few things are going on here:

1. Call our `toJSON()` function (the stimulus) and store the value
2. Ask for the returned value as a *typed* dictionary
3. *Chain* another optional as a `String` and assert

### What about force unwrapping?

Instead of all these crazy optionals and question marks, why don't we just force unwrap everything? **Better failure messages.** You tell me which you would rather debug.

```
Thread 1:
  EXC_BREAKPOINT (code=EXXC_I386_BPT, subcode=0x0)
```

```
XCTAssertEqual failed:
  ("Optional("Wingspan")") is not equal to ("Optional("Terraforming Mars")")
```

### Complete the test case

Fleshing out the rest of the assertions is straightforward. One thing I like to do is check the number of entries. That way I can ensure nothing extra is hanging out.

```swift
func test_toJSON() {
    let wingspan = BoardGame(name: "Wingspan", type: "Strategy", maxPlayers: 5)
    let json = wingspan.toJSON() as? [String: AnyObject]

    XCTAssertEqual(json?.count, 3)
    XCTAssertEqual(json?["name"] as? String, "Wingspan")
    XCTAssertEqual(json?["type"] as? String, "Strategy")
    XCTAssertEqual(json?["max-players"] as? Int, 5)
}
```

## What's next?

Optional chaining is a powerful tool for Swift developers working with XCTest. It allows us to gracefully fall back to `nil` while still keeping type safety. We can effectively communicate with the compiler and receive easy-to-read failure messages with just a few extra question marks.

In a future post, we will test a nested dictionary. For example, `BoardGame` could keep a reference to a `Publisher`. We will also explore refactors that help make some of this boilerplate code even easier to manage.
