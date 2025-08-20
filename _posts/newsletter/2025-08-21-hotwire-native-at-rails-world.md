---
title: "Hotwire Native at Rails World"
date: 2025-08-21
description: "Hotwire Native takes the Rails World 2025 keynote stage, plus updates on Ruby Friends for Android, native-feeling modals, and community projects."
---

Hey everyone,

Can you believe Rails World is so soon? Exactly two weeks from today I’ll be on stage delivering my talk on Hotwire Native.

But the most exciting part? **My talk was upgraded to a keynote!**

![Rails World keynote announcement](/assets/images/newsletter/rails-world-keynote-announcement.jpeg)

I’m excited and grateful to The Rails Foundation for giving me this opportunity. But I’d be lying if I said I wasn’t nervous. 🙈

As a tiny sneak peek, here’s one of my favorite slides from my deck so far. Just look at all of these apps built with Hotwire Native! They are all in the App Store and/or Google Play.

![Hotwire Native app icons](/assets/images/newsletter/app-icons.png)

If you’re attending Rails World then come say hi - I’d love to meet in person.

---

## From Masilotti.com

Since the last newsletter, I’ve been busy with two projects I’m excited to share.

### 🤖 [Ruby Friends Android app](https://play.google.com/store/apps/details?id=com.masilotti.rubyfriends&hl=en_US)

[Ruby Friends](https://rubyfriends.app) is now on Android! The app makes it easy to connect at conferences without the awkward “what’s your Twitter?” moment. Just set up a profile, scan someone’s code, and you’ll have a real connection to revisit later - long after the hallway track ends.

### 🎥 [Hotwire Native Modals](https://youtu.be/Sy1WYXlvDJ4)

Want your Hotwire Native apps to feel smoother? I published a 5 minute video showing how to make web-based modals behave like real native screens on iOS and android. No clunky overlays or awkward transitions - just fast, polished interactions that blend right in with the rest of your app.

---

## Hotwire Native around the web

Here's a few articles and announcements about Hotwire Native that caught my eye.

### 📲 [Action Native Push](https://dev.37signals.com/introducing-action-native-push/)

37signals released a new gem for sending iOS and Android push notifications. It connects directly to APNS and FCM, and takes care of retries, rate limiting, and cleaning up inactive devices automatically. If your app only needs to send push notifications, this looks like a compact, focused dependency. For broader notification management, check out [Noticed](https://github.com/excid3/noticed).

### 🚪 [Turbo adapter: Hotwire Native's backdoor entrance](https://radanskoric.com/articles/turbo-adapter-hotwire-native-backdoor-entrance)

> TL;DR: Hotwire Native injects a piece of JavaScript that integrates with the Turbo already present on the web and makes it talk to native mobile code.

This deep dive explains the magic behind how Hotwire Native bridges the web and native worlds. Essential reading for anyone looking to understand the underlying architecture.

### 👩‍💻 [The Rails World 2025 App is Back: Now Native & Built by the Community](https://www.teloslabs.co/post/the-rails-world-2025-app-is-back)

Rails World 2025’s official app is back and better than ever. The open source [iOS](https://github.com/TelosLabs/conference-ios-app) and [Android](https://github.com/TelosLabs/conference-android-app) conference app has been upgraded to Rails 8 and powered by Hotwire Native, delivering native experiences while still running as a progressive web app on desktop and mobile.

### 🖨️ [A bridge component in action](https://x.com/RobStortelder/status/1955648412520509819)

Rob Stortelder shared a demo triggering an Epson printer to spit out a receipt. Since most browsers prohibit requests to a local network, bridge components were the key to making it work seamlessly.

---

There’s so much exciting work happening in the Hotwire Native world right now, from new gems to open source apps to creative bridge components!

Again, if you’re heading to Rails World this year, I’d love to connect in person. If you see me around, don’t hesitate to come say hi.
