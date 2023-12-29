---
title: Swift mocks without protocols
date: 2020-12-24
description: How to reduce boilerplate by abusing inheritance to create mocks in Swift.
---

A true unit test mocks out the subject’s collaborators. If you’re testing the service layer you don’t want the HTTP client making real network requests in your test suite.

A common approach for creating these mocks is to use (abuse, really) Swift protocols. A protocol with a single implementation in the app and a mock "implementation" for tests.

This technique enables us to stub out whatever we need under test without worrying about the real implementation. However, it has a downside.  **You create an additional layer of indirection in your application code that is only needed for tests.**

An alternative I’ve been exploring recently is using inheritance instead of protocols to create my mocks. This approach has its own set of tradeoffs, but might work better to get up and running. Let’s dive in!

## Swift mocks with protocols

Here’s quick recap of my [Better unit testing with Swift]({% post_url 2020-03-31-better-swift-unit-testing %}) post. Feel free to skip this section if you are familiar with IDEPEM.

We have a board game service that builds a path to pass along to the HTTP service. The single test asserts that the path is built correctly. Everything not relevant has been removed or commented out.

```swift
// MARK: Application code.

protocol HTTPClientable {
    func get(_ path: String) -> Data
}

struct HTTPClient: HTTPClientable {
    func get(_ path: String) -> Data {
        // Actual implementation.
    }
}

struct BoardGameService {
    private let client: HTTPClientable

    init(client: HTTPClientable = HTTPClient()) {
        self.client = client
    }

    func fetchGame(id: Int) -> BoardGame {
        let json = client.get("/games/\(id)")
        // Parse the JSON and return a BoardGame.
    }
}
```

```swift
// MARK: Test code.

class MockHTTPClient: HTTPClientable {
    private(set) var get_path: String?

    func get(_ path: String) -> BoardGame {
        get_path = path
        // Return a fake BoardGame.
    }
}

class BoardGameServiceTests: XCTestCase {
    func test_fetchGame_buildsThePath() throws {
        let client = MockHTTPClient()
        let service = BoardGameService(client: client)
        service.fetchGame(id: 42)
        XCTAssertEqual(client.get_path, "/games/42")
    }
}
```

Again, the downside here is the phantom protocol, `HTTPClientable`. No where else in our app code are we going to use it. Its sole purpose is to wrap the real implementation so the test suite can stub it out.

## Converting to inheritance

Converting this protocol-based mocking to inheritance doesn’t require much work in the application code. All we need to do is remove the reference to the protocol and use the concrete type, `HTTPClient`.

```swift
struct HTTPClient {
    func get(_ path: String) -> Data {
        // Actual implementation.
    }
}

struct BoardGameService {
    private let client: HTTPClient

    init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }

    // ...
}
```

Out test suite doesn’t change much either. Update `MockHTTPClient` to *inherit* from `HTTPClient` instead of implementing the `HTTPClientable` protocol. Don’t forget the `override` call, too!

```swift
class MockHTTPClient: HTTPClient {
    override func get(_ path: String) -> Data {
        // ...
    }
}
```

However, this won’t compile. `HTTPClient` is a struct and we can’t inherit from those in Swift. Converting the client to a class solves our problem.

```swift
class HTTPClient {
    // ...
}
```

## Trade-offs

The big trade-off of inheritance-based mockss is we can no longer use structs. That means that even for tiny data-only objects we need to use a class.

Depending on your application this might have more serious consequences than is immediately obvious. **Swift structs are passed by values, not reference. Classes are passed by reference.** You might introduce a side effect or global state by converting your structs to classes.

A less obvious downside is that you, the developer, are responsible for overriding each new function. Say you add a new function to `HTTPClient`. With protocols Xcode would not compile until you implemented the same in your mock. You lose that safety net with classes and inheritence.

## Which do you use?

I’m experimenting with this new approach in a new project. So far it feels like I’m writing way less boilerplate and have fewer levels of indirection.

It’s also helped onboard new folks to the application who aren’t as familiar with testing. They can command-click on an object and go right to the definition, not having to deal with clicking through the protocol first.

What about you? Is this a technique you’ve tried? Are there less obvious downsides that I’m missing? I’d love to [hear what you think on Twitter](https://twitter.com/joemasilotti)!
