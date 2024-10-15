---
title: Turbo Native and pull-to-refresh
date: 2024-04-18
description: "How to set up pull-to-refresh in Turbo Native apps for iOS and Android via path configuration rules."
---

{% include warning.liquid %}

Earlier this week someone asked me on [my Discord](https://discord.gg/EE6yKspVWr) how to configure pull-to-refresh in their Turbo Native app. Matthew, the developer, is building an iOS and Android app that translates scribbled text to letters and numbers.

Drawing horizontally works fine. But every time you draw *down* the page refreshes.

![Drawing down triggers pull-to-refresh](/assets/images/turbo-native-pull-to-refresh/pull-to-refresh.gif){:standalone .unstyled.max-w-xs}

This gesture is triggering the pull-to-refresh control added to the web view by Turbo Native. Giving the user a way to refresh a page makes sense… but not for this screen. So what’s a developer to do?

Turns out this is one of the many things we can configure *without writing any native code*. Everything can be configured via a path configuration rule for both platforms.

## Path configuration on Android

From my last guide, [Turbo Native iOS and Android apps in 15 minutes]({% post_url 2024-03-28-turbo-native-apps-in-15-minutes %}):

> The *path configuration* is a JSON file that outlines a set of rules and settings for Turbo Native apps. On Android, it tells the library which web pages should be rendered via which fragment. It can also be used to configure modals, route native screens, and more.

Here is the minimum you need to get a path configuration working in Turbo Android:

```json
{
  "settings": {
    "screenshots_enabled": true
  },
  "rules": [
    {
      "patterns": [
        ".*"
      ],
      "properties": {
        "context": "default",
        "uri": "turbo://fragment/web"
      }
    }
  ]
}
```

The `settings` key enables screenshots via `screenshots_enabled`. When navigating *back*, a snapshot of the previous screen will be shown until the view finished loading (instead of a blank screen).

And the `rules` key declares an array of routing rules. Whenever a link is tapped the `patterns` key matches the URL path to determine what behavior to apply. The single rule used here routes *all* URL paths via the `.*` wildcard to the fragment identified by `turbo://fragment/web`.

We want to disable pull-to-refresh on specific pages. First, enable pull-to-refresh in the wildcard rule making it the default for all screens.

```json
{
  "settings": {
    "screenshots_enabled": true
  },
  "rules": [
    {
      "patterns": [
        ".*"
      ],
      "properties": {
        "context": "default",
        "uri": "turbo://fragment/web",
        "pull_to_refresh_enabled": true
      }
    }
  ]
}
```

Then add a second rule that disables the feature. Here we match all URLs that end in `/one`.

```json
{
  "settings": {
    "screenshots_enabled": true
  },
  "rules": [
    {
      "patterns": [
        ".*"
      ],
      "properties": {
        "context": "default",
        "uri": "turbo://fragment/web",
        "pull_to_refresh_enabled": true
      }
    },
    {
      "patterns": [
        "/one$"
      ],
      "properties": {
        "pull_to_refresh_enabled": false
      }
    }
  ]
}
```

Why `/one`? Tapping “Navigate to another webpage” in the demo app takes you to this URL, making it easy to test. Try it out by running the app and noticing where you can and cannot pull-to-refresh.

![Turbo Native Android demo app screenshots](/assets/images/turbo-native-pull-to-refresh/turbo-native-android-demo.png)

In your app make sure to change that path pattern to whatever makes sense.

With Android done let’s switch gears to iOS.

## Path configuration on iOS

The iOS side of [my guide]({% post_url 2024-03-28-turbo-native-apps-in-15-minutes %}) didn’t cover adding a path configuration because it isn’t needed to get started. So the first thing we need to do is wire one up. Sorry, you will have to write a bit of native code - but only two lines!

We’ll start with where the guide left off - a barebones Turbo Native iOS app. If you’re using your own project then make sure you are using the [turbo-navigator branch](https://github.com/hotwired/turbo-ios/pull/158) of turbo-ios. Here’s what the `SceneDelegate.swift` looks like at the end of the guide:

```swift
import Turbo
import UIKit

let baseURL = URL(string: "https://turbo-native-demo.glitch.me/")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigator = TurboNavigator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.rootViewController = navigator.rootViewController
        navigator.route(baseURL)
    }
}
```

First, create a new path configuration JSON file to bundle with your app. Click File → New → File… and select Empty from the Other heading.

![New file wizard](/assets/images/turbo-native-pull-to-refresh/new-file-wizard.png)

Name the file `path-configuration.json` and make sure the checkbox next to the app target is checked.

![Name file step](/assets/images/turbo-native-pull-to-refresh/name-file-step.png) 

When the file opens replace the contents with the following path configuration:

```json
{
  "settings": {},
  "rules": [
    {
      "patterns": [
        "/one$",
      ],
      "properties": {
        "pull_to_refresh_enabled": false
      }
    }
  ]
}
```

We don’t need to configure any custom settings so the `settings` key gets an empty hash. By default Turbo Native iOS automatically enables pull-to-refresh, so we only need a single rule to *disable* it on specific screens.

Open `SceneDelegate.swift` and create a new private property named `pathConfiguration`. Point this to a local `.file` source for the `path-configuration.json` file bundled with your app.

```swift
import Turbo
import UIKit

let baseURL = URL(string: "https://turbo-native-demo.glitch.me/")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigator = TurboNavigator()
    private let pathConfiguration = PathConfiguration(sources: [ // <---
        .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!) // <---
    ]) // <---

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.rootViewController = navigator.rootViewController
        navigator.route(baseURL)
    }
}
```

Finally, pass `pathConfiguration` into the `TurboNavigator` instance. Make sure to change `let` to `lazy var` to avoid the race condition.

```swift
import Turbo
import UIKit

let baseURL = URL(string: "https://turbo-native-demo.glitch.me/")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var navigator = TurboNavigator(pathConfiguration: pathConfiguration) // <---
    private let pathConfiguration = PathConfiguration(sources: [
        .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!)
    ])

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.rootViewController = navigator.rootViewController
        navigator.route(baseURL)
    }
}
```

Build and run the app - now every URL that ends in `/one` will no longer have a pull-to-refresh control installed. Perfect!

## What’s next?

This guide touched on one of the ways to drive behavior in the apps from your Rails server. You learned how to set up a path configuration on iOS and then use it to disable pull-to-refresh on specific screens.

I recommend reading through the [iOS](https://github.com/hotwired/turbo-ios/blob/main/Docs/PathConfiguration.md) and [Android](https://github.com/hotwired/turbo-android/blob/main/docs/PATH-CONFIGURATION.md) path configuration documentation next. Is there anything else that you can use to move more configuration from the native codebase to your server?
