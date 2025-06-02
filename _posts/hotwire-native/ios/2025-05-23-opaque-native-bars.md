---
title: Opaque navigation and tab bars in Hotwire Native – iOS
date: 2025-05-23
description: |
  A two-line fix for web content rendering "through" your transparent top and
  bottom bars (navigation bar and tab bar).
order: 6
---

iOS uses *transparent* native elements by default. Which means that a Hotwire Native app will render web content "through" the top bar (navigation bar) and bottom bar ([tab bar]({% post_url hotwire-native/ios/2025-05-23-tabs %})).

This might not be apparent until your web content fill the screen, as shown in the screenshot on the right. But when it occurs it can look quite jarring!

![](/assets/images/hotwire-native/ios/opaque-native-bars/transparent-bars.png){:standalone .unstyled}

Lucky for us the fix is quick. Add the following to `AppDelegate.swift`:

{% highlight swift mark_lines="8 9" %}
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UINavigationBar.appearance().scrollEdgeAppearance = .init()
        UITabBar.appearance().scrollEdgeAppearance = .init()

        return true
    }
{% endhighlight %}

This sets an *opaque* navigation bar and tab bar, ensuring the web content won’t render through. When implemented, you’ll also get a nice light gray background on both bars. Which, personally, I think looks even better.

![](/assets/images/hotwire-native/ios/opaque-native-bars/opaque-bars.png){:standalone .unstyled}
