---
title: "Hotwire Native: When to upgrade screens to native?"
date: 2023-08-29
description: Deciding when to go native and when to use web views in Hotwire Native apps, from experience.
---

Going hybrid with Hotwire Native doesn’t mean _every_ screen needs to be powered by a web view. While good enough for most of your app, there are times where a little more fidelity is required. Times when you want something a bit more… _native_.

There are no hard and fast rules about _when_ to go native. Every app is different. Remember, each native screen adds additional complexity and maintenance.

Here are a few examples I’ve picked up [building Hotwire Native apps for clients]({% post_url 2022-07-22-zero-to-app-store-in-7-weeks %}). I follow these rough guidelines to decide if a screen should be native or not.

## Three candidates for native screens

Going with a native **home screen** means the app can launch quickly and offer the highest fidelity available right away. HEY and Basecamp both follow this guidelines, launching directly to SwiftUI views. Bonus, they cache the data for offline access, further speeding up launch times.

![The native home screens of HEY and Basecamp - credit 37signals](/assets/images/when-to-upgrade-turbo-native-screens/native-home-screens.png){:standalone .unstyled}

Native **maps** offer a better user experience than web-based solutions. You can fill the entire screen with map tiles and tack on individual features as needed, like pins, overlays, or directions. And [MapKit](https://developer.apple.com/documentation/mapkit/) now works out of the box with both UIKit and SwiftUI, removing even more boilerplate.

![Native MapKit examples, annotations and an overlay](/assets/images/when-to-upgrade-turbo-native-screens/mapkit-examples.png){:standalone .unstyled}

Screens that interact with **native APIs** are often easier to build directly in Swift. I recently worked on a screen that displayed HealthKit data. By keeping everything native, the data flowed directly from the API to SwiftUI. But trying to render this via HTML would have required multiple roundtrips through [the JavaScript bridge]({% post_url turbo-ios/2021-04-02-the-javascript-bridge %}).

## Three screens better served by a web view

Screens that are **changed frequently**, like settings or preferences, are easier to manage when rendered via HTML. Changes on the web are cheap relative to native ones. A SwiftUI update often requires updates to the view _and_ the API. And each API change needs to ensure backwards compatibility with all previous versions.

![Frequently changed screens](/assets/images/when-to-upgrade-turbo-native-screens/frequently-changed-screens.png){:standalone .unstyled}

Boring, **CRUD-like operations** that aren’t unique to your app’s experience or product probably don’t need to be native. Yes, they might be fun to experiment with. But the time and resources spent are most likely better served working on critical workflows like the three examples above.

Rendering a lot of **dynamic content** is often faster to build with Hotwire. A list of heterogeneous items, like a news feed, requires each item type to be implemented as its own native view. And each _new_ item type requires an App Store release. Leaving all this logic and rendering to the server helps ensure the iOS app won’t block new features on the web.

## Or not at all

One more word of advice: you might not need _any_ native screens for your app’s initial launch.

Your initial App Store release should be as barebones as possible. It should do _just enough_ to ensure Apple will accept your app and publish it. You might end up wasting time implementing native features for an app that is never even available for download.

My priorities are always to get accepted in the App Store _then_ progressively enhance screens when needed. If you need a hand with _your_ app then please [reach out]({% link _pages/services.liquid %}) – I'd love to help!
