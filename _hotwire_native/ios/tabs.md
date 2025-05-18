---
title: Add a native tab bar in Hotwire Native – iOS
description: |
  Use HotwireTabBarController to configure a native UITabBar to switch between
  contexts in an iOS app.
order: 4
---

Tab bars are one of the most common navigation patterns in native apps. Because they are so prevalent, users understand how to use them and expect them in their apps.

Hotwire Native now comes with first-party support for native tabs. With `HotwireTabBarController` you can add a native tab bar to your app faster than ever.

{% include book/promo.liquid %}

To add native tabs to a Hotwire Native iOS app, we'll start with the code provided in the [official getting started guide](https://native.hotwired.dev/ios/getting-started). Then update the following two marked lines in `SceneDelegate.swift` (or copy paste this entire file into a new project).

{% highlight swift mark_lines="9 16" %}
import HotwireNative
import UIKit

let baseURL = URL(string: "http://localhost:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let tabBarController = HotwireTabBarController()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions)
    {
        window?.rootViewController = tabBarController
        navigator.start()
    }
}
{% endhighlight %}

A basic Hotwire Native iOS app uses a single `Navigator` to navigate between screens - we replaced that with the `HotwireTabBarController` and set it to the window's `rootViewController` to make it appear on the screen.

Then, tell the tab bar to render the tabs by calling `load()`. This takes an array of `HotwireTab` instances, which we will set up in an extension next.

{% highlight swift mark_lines="10" %}
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // ...

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions)
    {
        window?.rootViewController = tabBarController
        tabBarController.load(HotwireTab.all)
    }
}
{% endhighlight %}

At the bottom of the file (or a new one), extend `HotwireTab` to add the `all` static property. Swift extensions are like opening up classes or monkey patching in Ruby. They let us add functionality to classes, even ones we don't own like `HotwireTab` from Hotwire Native.

```swift
extension HotwireTab {
    static let all = [
        HotwireTab(
            title: "Posts",
            image: UIImage(systemName: "book.pages")!,
            url: rootURL.appending(path: "posts")
        ),

        HotwireTab(
            title: "Comments",
            image: UIImage(systemName: "bubble")!,
            url: rootURL.appending(path: "comments")
        )
    ]
}
```

Here we add two tabs to a demo blog application: one for posts and one for comments. The strings passed to `UIImage(systemName:)` reference icons provided by [SF Symbols,](https://developer.apple.com/sf-symbols/) a library from Apple that includes more than 5,000 symbols that you can freely use in iOS apps. I recommend downloading SF Symbols and digging through the plethora of options.

![The SF Symbols app, a listing of different icons like map pins, cars, and buses, with categories on the left and search/details on the right.](/assets/images/hotwire-native/tabs/ios/sf-symbols.png)

Bonus tip: Add the following line of code before you load the tabs. This darkens the background color of the tab bar, making it even more obvious.

```swift
UITabBar.appearance().scrollEdgeAppearance = .init()
```

Run the app and check out your native tab bar!

![Native tabs on Hotwire Native iOS](/assets/images/hotwire-native/tabs/ios/tabs.png){:standalone .unstyled}

Up next we'll add a native tab bar to our Hotwire Native Android app.
