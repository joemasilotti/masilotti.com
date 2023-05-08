---
title: Turbo Native workshop guide
description: |
  A guide for the Turbo Native workshop from Joe Masilotti.
permalink: /turbo-native-workshop/guide/

layout: page
template_engine: liquid

---

Welcome to the Turbo Native workshop. I can't wait to get started!

<p class="lead">Today you will learn how to use the Turbo Native iOS wrapper to build high-fidelity hybrid apps with native navigation.</p>

1. [An overview of the workshop](#workshop-overview)
2. [A topic outline with git tags](#workshop-topics)
3. [Links to additional resources](#additional-resources)

## Workshop overview

The workshop is split into multiple phases each covering a different Turbo Native topic.

I will work through each topic in the [companion app codebase](https://github.com/Turbo-Native-workshop/companion-app). As I code you are encouraged to follow along and apply the changes locally at the same time.

Don't worry if you fall behind - each phase has a "checkpoint" to get back up to speed. You can run `git checkout TAG_NAME` to check out the relevant code for the topic.

I'll also call out common pitfalls, gotchas, and tips that I've seen from my 6+ years building Turbo Native apps. We will wrap up each phase with a Q&A session on the topic.

**Please raise your hand (in Zoom) if you have any questions or I am moving too fast.**

## Workshop topics

> Note: To check out a tag run `git checkout TAG_NAME` from the repository.

### Phase 0: Project overview

Before we dive in let's take a look at what we are building. Make sure you have `main` checked out and start the server. Play around with the web app and native app to get a feel for what's to come.

### Phase 1: Getting started with Turbo Native

Let's dive in! In this phase we will cover how to add the turbo-ios Swift package, a basic Turbo Native integration, and handling errors. We will also touch on how to navigate and be efficient in Xcode.

Check out `phase-1` and let's begin.

### Phase 2: Making the app feel more native

The app is working great but some things feel a little *off*. That navigation bar at the top isn't very iOS friendly. And what's with every page saying "Board Game Shelf" at the top? Let's make the app feel a bit more native.

Check out `phase-2` and let's begin.

### Phase 3: Web-based authentication

This phase introduces a way for the iOS app to authenticate with the Rails app with very little native code. It leverages the existing Devise authentication and web-based sign in screens.

Check out `phase-3` and let's begin.

### Phase 4: Native screens with SwiftUI

What would a Turbo Native app be without a native screen or two?

Let's add a profile page for signed in users. First, we will add the HTML-based version then progressively enhance it with a SwiftUI-powered one. We will authenticate the native HTTP request with cookies shared from the web view.

Check out `phase-4` and let's begin.

## Additional resources

I've collected some useful links to help you on your way to building Turbo Native apps.

### Official resources

* [Turbo Native documentation](https://github.com/hotwired/turbo-ios/tree/main/Docs)
* [Turbo handbook](https://turbo.hotwired.dev/handbook/introduction)

### Unofficial resources

* [My 6-part blog series on Turbo Native]({% post_url 2021-05-14-turbo-ios %})
* [How to debug Turbo Native apps with Safari]({% post_url 2023-04-18-debug-turbo-native-apps-with-safari %})
* [Enhancing Turbo Native apps: How to hide web-rendered content]({% post_url 2023-02-09-progressively-enhanced-turbo-native-apps-in-the-app-store %})
* [Navigation bar buttons with Turbo Native](https://www.youtube.com/watch?v=vgLIWVWAYrg)

## Thank you!

Thank you again for attending this workshop. I hope you learned enough to get started on your own Turbo Native app!

If you have any questions we didn't cover please email me at [joe@masilotti.com](mailto:joe@masilotti.com) and I'll do my best to help.

I also have a variety of Turbo Native-related offerings, including:

* **Private, customized workshops** for you team - Best if you want to level up your team and build your own app.
* **Consulting work** – Best if you need an app ASAP and want me to build it.
* **Advisory engagements** – Best if you need support and advice while building an app.

I'm looking forward to hearing from you! 👋
