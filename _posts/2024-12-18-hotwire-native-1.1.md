---
title: Hotwire Native 1.1 released
date: 2024-12-18
description: "This release simplifies configuration, resolves bugs, and introduces new features, making it easier to build web-first native apps with Rails."
---

[Hotwire Native](https://native.hotwired.dev), a web-first framework for building native mobile apps with Ruby on Rails, just released version 1.1. This release makes configuring the framework more predictable, adds new modal presentation options, changes how to customize the user agent, and addresses a bunch of bugs and issues.

## [Hotwire Native iOS version 1.1](https://github.com/hotwired/hotwire-native-ios/releases/tag/1.1.0)

The major focus of this release is addressing issues and questions around configuration. Developers were unsure why certain settings weren’t applying or where exactly to place the code. Here’s what changed.

### Path configuration

Setting up your path configuration is now done once, [globally](https://github.com/hotwired/hotwire-native-ios/pull/55):

```swift
Hotwire.loadPathConfiguration(from: [
    .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
    .server(baseURL.appending(path: "configurations/ios_v1.json"))
])
```

**This is a breaking change.** You’ll need to migrate any per-`Navigator` configuration to this new global API.

### Global configuration

Speaking of global APIs, *all* Hotwire Native configuration should be completed before a `Navigator` instance is created. To encourage this, it is now recommended to handle configuration in `AppDelegate` instead of `SceneDelegate`, like so:

```swift
import HotwireNative
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Load the path configuration.
        Hotwire.loadPathConfiguration(from: [
            .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!).
            .server(baseURL.appending(path: "configurations/ios_v1.json"))
        ])

        // Register bridge components.
        Hotwire.registerBridgeComponents([
            FormComponent.self,
            MenuComponent.self,
            // ...
        ])

        return true
    }
}
```

This addresses several inconsistencies caused by a `Navigator` making its first request without being properly configured. If you’ve ever wondered why your bridge components weren’t being registered correctly, this update should help!

### Custom user agent

To set a [custom user agent](https://github.com/hotwired/hotwire-native-ios/pull/56) use the following:

```swift
Hotwire.config.applicationUserAgentPrefix = "My Application;"
```

Hotwire Native will automatically append a substring to your prefix which includes:

- "Hotwire Native iOS; Turbo Native iOS;" (for `hotwire_native_app?` in Rails)
- "bridge-components: [your bridge components];"

`WKWebView`'s default string will also appear at the beginning of the user agent.

Running the code above on an iPhone running iOS 18.2 sets the user agent to:

```
Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) My Application; Hotwire Native iOS; Turbo Native iOS; bridge-components: [form menu]
```

This is applied to all web views and should be done in `AppDelegate`.

**This is a breaking change.** You’ll need to migrate any code that calls `Hotwire.config.userAgent` to the new API.

## New modal presentation styles

We also snuck in a new feature. If you’re releasing your app on iPads you can now use [two new modal presentation styles](https://github.com/hotwired/hotwire-native-ios/pull/61): `pageSheet` and `formSheet`.

![pageSheet on the left, formSheet on the right](/assets/images/hotwire-native-1.1/pageSheet-formSheet.png){:standalone .unstyled}

To help with iPad UX, you can also disable the gesture that dismisses the modal. Without this, tapping anywhere outside the modal could accidentally dismiss it, losing unsaved information in a presented form.

Set the `modal_style` and `modal_dismiss_gesture_enabled` properties in your path configuration to use the new features. Note the underscore in the `modal_style` values!

```json
{
  "settings": {},
   "rules":[
      {
         "patterns":[
            "/custom/form"
         ],
         "properties":{
            "context": "modal",
            "modal_style": "page_sheet",
            "modal_dismiss_gesture_enabled": false
         }
      }
   ]
}
```

### Bug fixes

The global configuration changes make it more predictable how a `Navigator` behaves. They fix issues where bridge components might not be registered correctly and where path configuration might not apply on the first request. Remember, to take advantage of this do your configuration in `AppDelegate`.

The release also includes fixes for pages being requested more than once. It fixes an [issue](https://github.com/hotwired/hotwire-native-ios/pull/62) where presenting a modal would request the URL twice and an [issue](https://github.com/hotwired/hotwire-native-ios/pull/60) where submitted forms would request the “success” page multiple times.

## [Hotwire Native Android version 1.1](https://github.com/hotwired/hotwire-native-android/releases/tag/1.1.0)

Android already has global configuration via an `Application` subclass so there’s less in this release than on iOS.

### Custom user agent

To set a [custom user agent](https://github.com/hotwired/hotwire-native-android/pull/77) use the following:

```kotlin
Hotwire.config.applicationUserAgentPrefix = "My Application;"
```

Hotwire Native will automatically append a substring to your prefix which includes:

- "Hotwire Native Android; Turbo Native Android;"
- "bridge-components: [your bridge components];"
- The `WebView`'s default Chromium user agent string

Running the code above on a Pixel 9 Pro running Android 15 sets the user agent to:

```
My Application; Hotwire Native Android; Turbo Native Android; bridge-components: [form menu]; Mozilla/5.0 (Linux; Android 15; sdk_gphone64_arm64 Build/AE3A.240806.036; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/131.0.6778.105 Mobile Safari/537.36
```

**This is a breaking change.** You’ll need to migrate any code that calls `Hotwire.config.userAgent` to the new API.

### Bug fix

This release fixes an [issue](https://github.com/hotwired/hotwire-native-android/pull/78) where presenting a modal would request the URL twice.

## What’s next?

This release of Hotwire Native 1.1 simplifies configuration, fixes persistent bugs, and introduces useful new features like improved modal presentation styles. These changes make the framework more predictable and developer-friendly, providing a solid foundation for Rails developers to build mobile apps.

For me, it’s especially exciting as these updates make [my upcoming book]({% link _pages/book.liquid %}) even more relevant, removing the need for some workarounds and giving developers clearer guidance. I can’t wait to see how these improvements help you build better apps faster. Let me know what you think of the updates and if there’s anything you’d like to see covered in future releases!
