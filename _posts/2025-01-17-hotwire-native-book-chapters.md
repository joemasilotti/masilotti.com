---
title: "What you’ll learn in “Hotwire Native for Rails Developers”"
date: 2025-01-17
description: "Curious about my new book? Here’s a chapter-by-chapter breakdown of what you'll learn, with screenshots."
favorite: true
---

A lot of folks have been asking me what exactly they’ll learn in my new book, [Hotwire Native for Rails Developers]({{ site.data.urls.book }}). So here’s a quick chapter-by-chapter rundown of what’s inside.

The book guides you through building iOS and Android apps powered by your Rails server using [Hotwire Native](https://native.hotwired.dev/). The app we’ll build helps you track your favorite hikes, allowing you to add notes, tag locations, and upload photos. Each chapter adds new features to make the app feel more native while leveraging Swift and Kotlin APIs.

## Ch 1 - Build your first Hotwire Native apps

This chapter introduces Hotwire Native and helps you set up your local development environment. By the end, you’ll have basic hybrid apps running on iOS and Android, powered by your Rails backend.

![](/assets/images/hotwire-native-book-chapters/chapter1.png){:standalone .unstyled}

You’ll also get a crash course in Swift and Kotlin, laying the groundwork for integrating more native features later.

## Ch 2 - Control your apps with Rails

Learn how to drive your mobile apps entirely through Rails code without touching native code. You’ll customize the native title bar, apply conditional styles, and keep users signed in seamlessly.

![](/assets/images/hotwire-native-book-chapters/chapter2.png){:standalone .unstyled}

Notice how the duplicate "Hiking journal" titles from Chapter 1 are hidden, making the app feel more polished and native.

## Ch 3 - Navigate gracefully with path configuration

Path configuration is one of the most powerful—and sometimes confusing—features of Hotwire Native. This chapter demystifies it, showing you how to use it to present forms as modal screens (sliding in from the bottom), all while keeping business logic on the server.

![](/assets/images/hotwire-native-book-chapters/chapter3.png){:standalone .unstyled}

## Ch 4 - Add a native tab bar

Tab bars are a staple of native apps. In this chapter, you’ll learn how to add them to your Hotwire Native apps, connecting each tab to its own web view instance. Plus, you’ll ensure your server isn’t overloaded when the app starts.

![](/assets/images/hotwire-native-book-chapters/chapter4.png){:standalone .unstyled}

## Chs 5 + 6 - Render native screens with SwiftUI and Jetpack Compose

These chapters show you how to route, display, and populate fully native screens powered by SwiftUI and Jetpack Compose. Once you’ve completed these steps, you’ll be able to integrate virtually any native experience into your Hotwire Native apps.

![](/assets/images/hotwire-native-book-chapters/chapters56.png){:standalone .unstyled}

## Chs 7 + 8 - Build bridge components with Swift and Kotlin

Bridge components — previously called "Strada" — are tiny enhancements that blend web and native functionality. They’re perfect for adding native features without going all-in on native development. By the end of these chapters, you’ll know how to build dynamic, native components controlled by HTML and JavaScript.

![](/assets/images/hotwire-native-book-chapters/chapters78.png){:standalone .unstyled}

## Ch 9 - Deploy to Physical Devices with TestFlight and Play Testing

If you build an app and never deploy it...is it really an app? And if you don't deploy your app, there's no way to show off your hard work to your friends and colleagues! This chapter walks you through getting your apps on real, physical devices. You'll deploy the iOS app with TestFlight, a first-party app from Apple that lets folks download apps for beta testing before they arrive in the App Store.

![](/assets/images/hotwire-native-book-chapters/chapter9.png){:standalone .unstyled}

## Chp 10 - Send Push Notifications with APNs and FCM

Push notifications are instant, reliable, and drive higher engagement than email or SMS. And even with recent enhancements to Progressive Web Apps (PWAs), native apps are still the best way to send reliable, timely notifications. Learn how to send them to your app with APNs and FCM in this chapter.

![](/assets/images/hotwire-native-book-chapters/chapter10.png){:standalone .unstyled}

You can grab your copy of the book today on [The Pragmatic Bookshelf website]({{ site.data.urls.book }}).

{% include book/cta.liquid %}
