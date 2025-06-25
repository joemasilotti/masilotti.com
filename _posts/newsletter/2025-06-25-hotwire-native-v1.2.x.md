---
title: "Hotwire Native v1.2.x and Hotwire Native LIVE #4"
date: 2025-06-25
description: "A quick update on the latest Hotwire Native releases and a countdown to RailsConf."
---

Hey folks, everyone getting ready for RailsConf? Can you believe it is only two weeks away!

I just wrapped up the slides for the workshop I’m running on Wednesday. Attendees will build Hotwire Native apps on iOS and Android from scratch, including a native tab bar and bridge component.

You’ll walk away from the workshop with a solid foundation on how to bring your own Rails app to mobile.

If you’re heading to the conference please say hello! I’d love to meet you IRL.

## Hotwire Native v1.2.x released

Hotwire Native saw two patch releases this week with v1.2.1 on iOS and v1.2.3 on Android.

This is the first time the different platforms diverged on releases. Here’s what’s included in each.

### Android

Earlier this month Android received two patch releases with [v1.2.1](https://github.com/hotwired/hotwire-native-android/releases/tag/1.2.1) and [v1.2.2](https://github.com/hotwired/hotwire-native-android/releases/tag/1.2.2). Both of these updated under-the-hood infrastructure. From a developer’s perspective, nothing actually changed but the version number.

**It’s safe to ignore these and go right to [v1.2.3](https://github.com/hotwired/hotwire-native-android/releases/tag/1.2.3)**, which adds two new features:

1. [PR #148](https://github.com/hotwired/hotwire-native-android/pull/148): If you’ve ever seen a 406 error then you’ll appreciate this one. Out-of-date Android clients will now see a more descriptive error message if the underlying web browser is out of date.
2. [PR #149](https://github.com/hotwired/hotwire-native-android/pull/149): This adds a way to show/hide the first-party tab bar programatically. While already included by default on iOS, we now have feature parity between the two platforms. I’m working on a `TabBarComponent` for my [bridge component library]({% link _pages/bridge-components.liquid %}) to take advantage of this. Stay tuned!

### iOS

iOS’s sole release with [v1.2.1](https://github.com/hotwired/hotwire-native-ios/releases/tag/1.2.1) fixed some tests in [PR #131](https://github.com/hotwired/hotwire-native-ios/pull/131) and restored support for running the demo app on iOS 15 in [PR #128](https://github.com/hotwired/hotwire-native-ios/pull/128).

But most importantly it added a new path configuration property, `queryStringPresentation`, to match behavior on Android.

Set this to `"replace"` and navigating between URLs where *only the query string changes* will replace the current screen on the stack (instead of pushing a new one).

This is mostly helpful for web-based tabs that require roundtrips to the server. However, it does *not* fix the flickering issue outlined in [#53](https://github.com/hotwired/hotwire-native-ios/issues/53). Hopefully we can get that fixed soon!

## Tomorrow: Hotwire Native LIVE - Route Decision Handlers

While reviewing through the code on these releases I realized I still haven’t used the new [Route Decision Handlers](https://github.com/hotwired/hotwire-native-ios/blob/main/Source/Turbo/Navigator/Routing/RouteDecisionHandler.swift) on iOS. These were brought over from Android in [v1.2.0](https://github.com/hotwired/hotwire-native-ios/releases/tag/1.2.0).

We can use these to customize behavior when navigating between URLs. Think “external URL handlers” but on steroids.

I’m exploring how to use these tomorrow (Thursday)! Join me for [episode #4 of Hotwire Native LIVE](https://youtube.com/live/t6niKGnKJQs). And please, bring your questions - I'll dedicate time at the end for Q&A.

<iframe class="w-full aspect-video" src="https://www.youtube-nocookie.com/embed/t6niKGnKJQs?si=YBTv4BBYASYrmdS_" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

I hope to see you there.
