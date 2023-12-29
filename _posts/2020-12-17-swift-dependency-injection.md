---
title: Roll your own dependency injection in Swift
date: 2020-12-17
description: Our own DI without third-party libraries. Build a robust, extendible micro-framework you can use in all your apps.
---

Dependency injection, or DI, is a key piece of the Swift testing puzzle. It gives you necessary control over how your subject under test interacts with its collaborators.

Without dependency injection we can’t mock out interactions farther down the stack. Our "unit tests" become integration tests at best, and unpredictable at worst.

Instead of reaching for a third-party library, let’s build out our own little DI. By the end of this post you will have a robust, extendible framework you can use in all your apps.

## Why dependency injection?

This article focuses on one major advantage of DI: making it easier to test things.

With dependency injection we can pass along a mock, fake, or test double to our subject under test. This decouples it from the inherit behavior and enables us to test in isolation.

If you need a recap on Swift dependency injection, check out [Better unit testing with Swift]({% post_url 2020-03-31-better-swift-unit-testing %}).

## Multiple dependencies are hard to read

First, let’s touch on a big pain point of initializer-based injection. As an object’s dependencies grow it gets harder and harder to understand exactly what’s going on.

```swift
struct Controller {
    private let router: Routable
    private let coordinator: Coordinatable
    private let presenter: Presentable

    init(router: Routable = Router(), coordinator: Coordinatable = Coordinator(), presenter: Presentable = Presenter()) {
        self.router = router
        self.coordinator = coordinator
        self.presenter = presenter
    }
}
```

This initializer is already 121 characters, and it isn’t getting shorter any time soon.

## Extract dependencies to a single object

A first pass at cleaning this up is to wrap everything up in one object.

```swift
struct Injector {
    let router: Routable = Router()
    let coordinator: Coordinatable = Coordinator()
    let presenter: Presentable = Presenter()
}
```

Now we can inject a single instance into our subject under test and grab all our dependencies from there.

```swift
struct Controller {
    // ...

    init(injector: Injector) {
        self.router = injector.router
        self.coordinator = injector.coordinator
        self.presenter = injector. presenter
    }
}
```

But we lost our code seam to inject fakes or mocks when under test.

## Abstract to a protocol

To regain our code seam lets abstract the injector to a protocol. Then our test suite can use its own fake representation.

```swift
protocol Injectable {
    var router: Routable { get }
    var coordinator: Coordinatable { get }
    var presenter: Presentable { get }
}
```

Our application code only requires a single change: defaulting the initialized variable.

```swift
struct Controller {
    // ...

    init(injector: Injectable = Injector()) {
        // ...
    }
}
```

This initializer is much easier to read! And our tests can now inject their fake instance.

```swift
struct FakeInjector: Injectable {
    let router: Routable = FakeRouter()
    let coordinator: Coordinatable = FakeCoordinator()
    let presenter: Presentable = FakePresenter()
}

let injector = FakeInjector()
let controller = Controller(injector: injector)
// ...
```

 `FakeInjector` has the added benefit of only requiring instantiating fakes we care about. We let the fake coordinator do its job (nothing) and only care about interaction with the router.

```swift
controller.tapButton("Read blog")
XCTAssert(injector.router.lastPath, "/blog")
```

But we still have one issue. Each instance is being instantiated every single time we create the injector. If `Router` is at all expensive it to create it could have a huge impact on performance.

## Make all variables lazy

To solve for this we convert the injector to a `class` and make all the properties `lazy`. This ensures that they are only created when needed, and not before. It also has the bonus benefit of breaking circular dependencies.

```swift
class Injector: Injectable {
    lazy var router: Routable { Router() }()
    lazy var coordinator: Coordinatable { Coordinator() }()
    lazy var presenter: Presentable { Presenter() }()
}
```

We could apply the same approach to the `FakeInjector` but it’s not necessary. Your fakes/mocks should be tiny and easy to spin up. No need to make any other code changes.

## Taking it further

I’ve been using some version of this approach on all my projects since I discovered it. It’s concise, has a very small surface area, and all without third-party code.

The big downside is the `Injectable` protocol and associated classes tend to grow fast. I'm keeping things organized with liberal use of `MARK:`s.

How do you do dependency injection in Swift? Do you use a particular library or are you more inclined to roll your own? [I'd love to know what you think on Twitter!](https://twitter.com/joemasilotti)
