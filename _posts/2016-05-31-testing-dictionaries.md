---
layout: post
title:  "Testing Dictionaries with Swift and XCTest"
date:   "2016-05-31"
permalink: testing-dictionaries/
image: images/twitter/testing-dictionaries.png
large_image: images/true
description: "A type-safe approach to testing dictionaries in Swift with clean failure messages."
category: testing-swift
---

Dictionaries are the ultimate data courier. They can encapsulate different types of information to pass around your codebase. However, their very nature of dynamism makes them tricky to test in Swift. With a few rules, you can easily create robust, complete, and statically typed XCTest test cases for dictionaries.

To explain how I go about testing dictionaries, we will walk through a simple example: generating JSON from a model object. Yes, there are many libraries/posts on this but I will concentrate my efforts on *testing* the output, not generating it.

## The Test Subject: `Beer().toJSON()`

[I like beer](https://www.instagram.com/p/BFpTsVwhSbD/?taken-by=joemasilotti). Like, [a lot](https://www.beermenus.com/people/72769). Beer also happens to translate well to a data model. It has string values, number values, and even nested attributes. For this post we will keep the modeling simple and use the following representation.

```swift
struct Beer {
    let name: String
    let brewery: String
    let ABV: Double
}
```

Nice and simple, just a few properties. The function we are interested in, `toJSON()`, is just as straightforward.

```swift
func toJSON() -> AnyObject {
    return ["name": name, "brewery": brewery, "abv": ABV]
}
```

Let's create the test case, now that we have our data model (and function implemented).

##  The "Simple" Test

The `toJSON()` function returns a few basic `String` and `Double` keys and values. Let's write a quick test to verify that they were all set correctly.

![Error Message: 'AnyObject' is not convertible to '[String : String]'; did you mean to use 'as!' to force downcast?](/images/not-convertible-error.png)

Oh no! Swift doesn't know how to compare our dictionary to the `AnyObject` return type of the function. And we can't cast value to `[String: String]` since we have both a `String` and `Double` value.

So, what do we do?

## Enter Optional Chaining

Swift is pretty fussy when it comes to types. It starts pouting if it doesn't know *exactly* what you are tying to compare. To give our favorite language a hand, we can take advantage of a technique called "optional chaining".

With this approach, we give hints to the compiler as to what type we *expect* a value to be. The call will return `nil` if the type is different. So, enough theory, here it is in practice.

```swift
class BeerTests: XCTestCase {
    func testToJSON() {
        let forcefield = Beer(name: "Forcefield", brewery: "Grimm", ABV: 6.5)
        let json = forcefield.toJSON() // 1
        let jsonDictionary = json as? [String: AnyObject] // 2
        XCTAssertEqual(jsonDictionary?["name"] as? String, "Forcefield") // 3
    }
}
```

So, a few things are going on here:

1. Call our `toJSON()` function (the stimulus) and store the value
2. Ask for the returned value as a *typed* dictionary
3. *Chain* another optional as a `String` and assert

### What About Force Unwrapping?

Instead of all these crazy optionals and question marks, why don't we just force unwrap everything? **Better failure messages.** You tell me which you would rather debug.

![Bad Failure Message: ](/images/bad-fail.png)

![Good Failure Message: "Forcefield" is not equal to "Future Perfect"](/images/good-fail.png)

### Complete Test Case

Fleshing out the rest of the assertions is straightforward. One thing I like to do is check the number of entries. That way I can ensure nothing extra is hanging out.

```swift
class BeerTests: XCTestCase {
    func testToJSON() {
        let forcefield = Beer(name: "Forcefield", brewery: "Grimm", ABV: 6.5)

        let json = forcefield.toJSON() as? [String: AnyObject]

        XCTAssertEqual(json?.count, 3)
        XCTAssertEqual(json?["name"] as? String, "Forcefield")
        XCTAssertEqual(json?["brewery"] as? String, "Grimm")
        XCTAssertEqual(json?["abv"] as? Double, 6.5)
    }
}
```

## What's Next?

Optional chaining is a powerful tool for Swift developers working with XCTest. It allows us to gracefully fall back to `nil` while still keeping type safety. We can effectively communicate with the compiler and receive easy-to-read failure messages with just a few extra question marks.

In a future post, we will test a nested dictionary. For example, `Beer` could keep a reference to a `Brewery`. We will also explore refactors that help make some of this boilerplate code even easier to manage.
