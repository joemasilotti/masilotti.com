---
title: A roadmap for building Hotwire Native apps
date: 2024-01-25
description: The approach I follow for every Hotwire Native app I build, including which app store to submit to first and how to prioritize work.
---

Last week 40+ folks joined me for a [live Q&A session on Turbo Native + rails](https://www.youtube.com/watch?v=z5vlVeLf9Nw). I answered 20ish questions over the 90 minute session.

But of all the questions, one really stuck out. It touches on an essential part of building Hotwire Native apps. And I haven’t spoken about it publicly yet!

> What’s my roadmap for building Hotwire Native apps?

Getting started with Hotwire Native apps can feel overwhelming, especially with *multiple* new platforms to learn. It’s important to know how to prioritize work to get into the app stores as quickly as possible.

I follow this approach for every Hotwire Native app I build. I apply it to personal projects, like [Daily Log](https://dailylog.ing), and my [client work]({% link _pages/services.liquid %}) as well. Follow my guide for the most effective way to launch your own apps to both app stores.

## 1. Build mobile-friendly web screens

My first step starts before I even open Xcode or Android Studio.

First up is making sure there are enough mobile-friendly web screens built. At its core, Hotwire Native renders web content in native chrome. So having a good sampling of screens already complete will kick start our Hotwire Native development.

At a minimum, you’ll want mobile-friendly screens for at least **three static pages** and **one form flow**. The static screens ensure that the core navigation between pages works correctly. And the form pushes your hybrid apps to present and dismiss modals. Both are key to making our hybrid app feel like a native one.

Finally, [Turbo Drive](https://turbo.hotwired.dev/handbook/drive) must be enabled to ensure page transitions happen smoothly. This is the default setting for new Rails apps created with Hotwire. But I’ve also worked in non-Rails codebases that bolted-on the Turbo JavaScript without issue.

## 2. Launch the iOS app to the App Store

The next step is getting your app approved and live in one of the app stores. **And if you’re launching on both platforms then submit to Apple first.**

Launching an iOS app to the App Store is _way_ more difficult than launching an Android app to Google Play. I should know, I've done this 20+ times! This is mostly because the [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) are more strict than Google Play’s [policies](https://developer.android.com/distribute/play-policies).

Apple might dictate that you *must* add in-app purchases. Or add a link to completely delete the user’s account. Addressing all of these while focusing on a single platform means less overall work. You won’t have to go back and forth between iOS and Android while struggling to stay on top of both submissions at the same time.

<p class="note">Check out my collection of <a href="{% post_url 2023-08-14-turbo-native-app-store-tips %}">App Store submission tips</a> with examples from real apps I've worked on.</p>

Finally, **don’t try to launch a pixel-perfect app right now.** Your goal is to get into the app stores as quickly as possible. Take advantage of Hotwire Native! Use your existing web screens as much as possible and only upgrade to native when absolutely necessary.

## 3. Launch the Android app to Google Play

Once your app is in the App Store then it’s time to move on to Android. By now you've ideally identified most of the thorny bits. Building the Hotwire Native integration on Android will be more straightforward.

Follow the same recommendation as above and **build something that works. Nothing more.**

Note that there is an exception to this step. Are most of your users are accessing your mobile website via Android devices? If so, launching to Google Play first might make more sense.

## 4. Progressively enhance high-impact screens

By now you’ve launched your apps to both app stores - congratulations! That’s no small feat.

Up next is upgrading these apps to feel more native. This includes adding [native components via Strada]({% post_url 2023-09-21-strada-launch %}) or converting pages to fully native screens.

**Great candidates for native include home screens, maps, and anything dealing with native APIs.** High-impact screens, like ones that are core to your business’s unique offering, should also be considered. Reference [this short guide]({% post_url 2023-08-14-turbo-native-app-store-tips %}) I wrote for help deciding when upgrading to native makes sense.

## But how do I get started?

You now have a solid roadmap for building and launching your iOS and Android Hotwire Native apps. But actually *writing* the code is an entirely different journey!

Here are some resources to help you along your way:

- [Hotwire Native for Rails developers]({% link _pages/book.liquid %}) - My upcoming book for Rails developers with *zero* Swift or Kotlin experience.
- [Just enough Turbo Native to be dangerous](https://www.youtube.com/watch?v=hAq05KSra2g) - My 30m talk at Rails World with a live coding demo.
- [Hybrid iOS apps with Turbo]({% post_url 2021-05-14-turbo-ios %}) - 6-part series building Turbo Native apps on iOS.
- [How to Get Up and Running With Turbo Android](https://williamkennedy.ninja/android/2023/05/10/up-and-running-with-turbo-android-part-1/) - The first post of a series on Turbo Native Android development from William Kennedy.

And if you’re looking for a more hands-on approach then check out [how I can help]({% link _pages/services.liquid %}). I've worked with dozens of businesses to launch their Rails app to the app stores. And I’d love to do the same for you!
