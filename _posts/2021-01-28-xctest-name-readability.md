---
title: Improving XCTest test name readability
date: 2021-01-28
description: 5 lines of code go a long way in making your test names much more readable.
---

Naming things is hard. And naming tests is no exception. But XCTest adds another layer of complexity: test names have to be functions.

The framework creates a test for every function that starts with "test" in your `XCTestCase` subclass. Examples from [Apple’s docs](https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods) include:

```swift
class NetworkReachabilityTests: XCTestCase {
    func testUnreachableURLAccessThrowsAnError()
    func testUserJSONFeedParsing()
}
```

I find these a bit hard to understand. Humans weren’t meant to read camel case, that’s why we have spaces!

To give my tests a little more context, I do as [Jon Reid recommends](https://qualitycoding.org/unit-test-naming/). I name my tests in three parts:

1. Given - the operation being testing
2. When - under what circumstances
3. Then - the expected result

Each section is written in camel case and each section is separated by an underscore.

```swift
func test_givenSomething_whenSomething_thenSomething()
func test_numberOfCells_withNoData_isZero()
```

This boosts readability a bit, but it is still very hard to parse quickly. I would much rather write tests like Kotlin, as a string.

```kotlin
class MyTestCase {
     @Test fun `number of cells with no data is zero`()
}
```

Turns out, we can get something very close to this Swift, but there are a few tradeoffs.

## XCTContext and XCTActivity

Another hidden XCTest gem appears! From [the docs on `XCTActivity`](https://developer.apple.com/documentation/xctest/xctcontext):

> You can break up long test methods in UI tests or integration tests into activities to reuse, and to simplify results in the Xcode test reports.

There isn’t any sample code, so here’s a quick example of how to work with this API.

```swift
class TestCase: XCTestCase {
    func test_numberOfCells() throws {
        XCTContext.runActivity(named: "is zero when there is no data") { _ -> Void in
            /* ... */
        }

        XCTContext.runActivity(named: "is equal to the number of items") { _ -> Void in
            /* ... */
        }
    }
}
```

Not bad! We’ve now moved the function we are testing, `numberOfCells`, to the test name and split out the hard to read text into a string. But we can do one better.

## Cleaning things up with an extension

Add the following extension to your test suite.

```swift
extension XCTestCase {
    func test<T>(_ description: String, block: () throws -> T) rethrows -> T {
        try XCTContext.runActivity(named: description, block: { _ in try block() })
    }
}
```

The code should look pretty similar to the example above but with two major differences. We are wrapping everything in "test" and ignoring the return value. This cleans up our call site quite a bit.

```swift
class TestCase: XCTestCase {
    func test_numberOfCells() throws {
        test("is zero when there is no data") {
            /* ... */
        }

        test("is equal to the number of items") {
            /* ... */
        }
    }
}
```

I really like how this reads. It’s obvious what’s going on and each assertion gets its own space to breath. However, there are a few downsides to this approach.

## Trade-offs

The code in the example above only generates one test (not two). Each reports their failure/error separately, but the number at the end of the logs would only read `Executed 1 test, with 0 failures`.

And because of how XCTest groups these, you can’t run one without the other. Only one little diamond appears on the file, not on each context.

Finally, you are now _always_ an additional "layer" nested. Instead of writing tests at level 2 (class -> function) you are now at level 3 (class -> function -> activity). This doesn’t bother me too much, but it is worth calling out.

## Quick library

You could also accomplish this with a BDD-style testing library like [Quick](https://github.com/Quick/Quick). If you are familiar with RSpec you will feel right at home here. Describe, contexts, it blocks, even asynchronous testing is built in.

```swift
class TableOfContentsSpec: QuickSpec {
  override func spec() {
    describe("the ‘Documentation’ directory") {
      it("has everything you need to get started") {
        let sections = Directory("Documentation").sections
        expect(sections).to(contain("Organized Tests with Quick Examples and Example Groups"))
        expect(sections).to(contain("Installing Quick"))
      }

      context("if it doesn’t have what you’re looking for") {
        it("needs to be updated") {
          let you = You(awesome: true)
          expect{you.submittedAnIssue}.toEventually(beTruthy())
        }
      }
    }
  }
}
```

Recently, I’ve been trying to use XCTest directly. So I’ve passed on adding Quick to my projects. I also kind of despise nested tests like this, but that’s an article for another day!

## How do you test?

Looking ahead, I’d love to create a micro-library that can generate tests on the fly. Think Quick, but without any of the nesting or BDD stuff.

What do you use to test your Swift code? Do you use any third-party libraries? I’d love to know! [Mention or DM me on Twitter](https://twitter.com/joemasilotti) to get in touch.

## References

A lot of this post was inspired by [this article](https://medium.com/flawless-app-stories/ios-achieving-maximum-test-readability-at-no-cost-906af0dbaa98) from Flawless App Stories. Thanks Victor!
