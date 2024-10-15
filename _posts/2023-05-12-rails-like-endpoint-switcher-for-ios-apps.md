---
title: A Rails-like endpoint switcher for iOS apps
date: 2023-05-12
description: A copy-pasteable code snippet to bring a little Rails magic to your iOS app.
---

Writing Ruby on Rails comes with a great developer experience that is easy to take for granted when you start writing iOS code.

Take, for example, the environment helper. I can call `Rails.env` and get a string representation of the current environment, like “development”.

I can also ask explicit questions like `Rails.env.development?` to check if the app is running in development. Or, my favorite, [`Rails.env.local?`](https://github.com/rails/rails/pull/46786) to see if we are running in development *or* test.

## iOS conditional complication

In iOS we have something similar, but not quite as elegant.

Swift has a concept of build configurations. By default, Debug includes debugging symbols for setting breakpoints and spelunking through code. Where Release strips these and optimizes for release in the App Store.

You can change your build configuration by opening the scheme in Xcode via Product → Scheme → Edit Scheme… For context, I only ever use Release when packaging an app for the App Store.

![Build Configuration setting in Xcode](/assets/images/rails-like-endpoint-switcher-for-ios-apps/build-configuration.png){:standalone .unstyled}

Building on this, you can use Swift’s conditional complication. You can wrap code in a special `#if` statement that will only get compiled based on the build flavor.

```swift
#if DEBUG
print("Only compiled in DEBUG build mode.")
#else
print("Only compiled in non-DEBUG build mode.")
#endif
```

But there’s no build configuration for production or staging in Swift. And creating a new one requires [a lot of manual effort and upkeep](https://sarunw.com/posts/how-to-set-up-ios-environments/). At least, too much work for a spoiled Rails developer like me!

## A Rails-like environment helper for iOS apps

When building Hotwire Native apps I like to borrow Rails paradigms and bring them to iOS. So for an *environment helper* I want to mimic the Rails API and spirit. To me, that means:

- Development - app was installed via Xcode
- Staging - app was downloaded via TestFlight
- Production - app was downloaded via the App Store

To solve this I put together a [copy-pasteable gist](https://gist.github.com/joemasilotti/ed002068cc1239d5e799fae1e4038386) that I bring to every new project I start.

Under the hood it uses embedded mobile provisioning profiles, App Store sandbox receipts, conditional complication, and a whole bunch of other iOS mumbo jumbo.

**But all the logic is wrapped in a nice, Rails-like API via an enum.** Meaning we can do this:

```swift
// A single check.
if Environment.current.isDevelopment {
    print("App was installed via Xcode")
}

// Switch over all three cases.
switch Environment.current {
case .development:
    print("App was installed via Xcode.")
case .staging:
    print("App was downloaded via TestFlight.")
case .production:
    print("App was downloaded via the App Store.")
}
```

## Changing endpoints based on environment

I use this in my [Hotwire Native apps]({% post_url 2021-05-14-turbo-ios %}) to change the root endpoint based on the environment.

This ensures the app automatically points to the right URL. When I build to the simulator from Xcode I hit my local server. And folks who download from the App Store hit the production endpoint.

```swift
enum Endpoint {
    static var root: URL {
        switch Environment.current {
        case .development:
            return URL(string: "http://localhost:3000")!
        case .staging:
            return URL(string: "https://dev.masilotti.com")!
        case .production:
            return URL(string: "https://masilotti.com")!
        }
    }
}

let rootURL = Endpoint.root
```

Again, here’s a link to the [`Environment.swift` gist](https://gist.github.com/joemasilotti/ed002068cc1239d5e799fae1e4038386). Feel free to copy-paste it into any Xcode project.

I hope that helps bring a little Rails magic to your Hotwire Native apps! If you need more help don’t hesitate to reach out by [sending me an email](mailto:joe@masilotti.com).
