---
description: A guide.
image:
layout: page
permalink: turbo-native-workshop/guide/
title: "Turbo Native workshop guide"

---

Welcome to the Turbo Native workshop. I can’t wait to get started!

<p class="lead">Today you will learn how to use the Turbo Native iOS wrapper to build high-fidelity hybrid apps with native navigation.</p>

This guide includes:

1. [An overview of the workshop](#overview)
2. [A topic outline with git tags](#topics)
3. [Links to additional resources](#resources)

<h2 id="overview">Workshop overview</h2>

The workshop is split into multiple phases each covering a different Turbo Native topic.

Each phase will start with some live coding to build out a feature. I will walk through each step and call out common pitfalls, gotchas, and tips that I’ve seen from past projects. **Please raise your hand (in Zoom) if you have any questions.**

Then you will work through an activity on your own. This will give you a chance to do some coding and ensure the concepts stick.

We will wrap up each phase with an example solution to the activity and a Q&A session on the topic.

<h2 id="topics">Workshop topics</h2>

> Note: To check out a tag run `git checkout TAG_NAME` from the repository.

### Phase 0: Project overview

Before we dive in let’s take a look at what we are building. Make sure you have `main` checked out on both the iOS and Rails repo. Play around with the web app and native app to get a feel for what’s to come.

### Phase 1: Turbo Native integration and overview

Let’s dive in! In this phase we will cover some high-level iOS concepts, integrating Turbo Native, pushing/popping/presenting controllers, the Path Configuration, and handling errors.

Check out `phase-1` on both repos to begin.

### Phase 1: Activity

Spend 5 minutes poking around and jot down things that feel “off” or weird in the app.

The code we have so far is most of what you get from the Demo app in the Hotwire repo. Let’s see how many issues we can fix today.

### Phase 2: Native look and feel

The app is working great but some things feel a little *off*. That navigation bar at the top isn’t very iOS friendly. And what’s with every page saying “Board Game Shelf” at the top? Let’s make the app feel a bit more native.

Check out `phase-2` on both repos to begin.

### Phase 2: Activity

We successfully replaced a screen when signing in and out. But what about when updating a game? Let’s apply the same logic – be careful not to break the flow when adding a new game, though!

Check out `phase-2-activity` on **the Rails repo (only)** to begin.

### Phase 3: Web-based authentication

This phase introduces a way for the iOS app to authenticate with the Rails app with (relatively) little native code. It leverages the existing Devise authentication and web-based sign in screens.

Check out `phase-3` on both repos to begin.

### Phase 3: Activity

Authentication is looking good! But there’s a bug that can cause some confusion for users.

Follow these steps to reproduce it:

1. Sign out and rerun the app
1. Tap a game
1. Tap edit
1. Sign in
1. Dismiss the edit screen
1. Tap the back button

When you open the navbar we are no longer signed in!

Here’s a chance to learn how to fix Turbo Native issues on your own. Start by diving into the  [documentation](https://github.com/hotwired/turbo-ios/tree/main/Docs)  and maybe even the  [source code for the demo app](https://github.com/hotwired/turbo-ios/tree/4b313588654acf62675b9870cf780b2300585cbf/Demo) .

Check out `phase-3-activity` on **the iOS repo (only)** to begin.

### Phase 4: JavaScript bridge

So far we only have two ways to communicate between the Rails and iOS apps: HTTP status codes and URL routing. What if we want to get a little more granular?

Enter the JavaScript bridge. Here we can pass messages back and forth between the two apps any time an HTML screen is rendered. This gives a ton of flexibility to keep our logic in the Rails app and tell the iOS side to do generic (but native!) things.

Check out `phase-4` on both repos to begin.

### Phase 4: Activity

Now that we have a feel for native buttons let’s add another! Add a `+` button on the right side of the Home Screen. When clicked, push the "Add a game" page.

Check out `phase-4-activity` on both repos to begin.

### Phase 4: JavaScript bridge part 2

These native buttons are great – they enable us to call into native code with a bit of scaffolding and JavaScript. But they are a little rigid. What if we could make them a bit more flexible?

Refactoring, we can make our button more dynamic. So dynamic that the iOS app only needs to know two things: what symbol to show and what DOM element to click.

Undo your changes to reset back to `phase-4-activity` on both repos to begin.

### Phase 5: Native screens

What would a Turbo Native app be without a native screen or two?

Let’s add a profile page for signed in users. First, we will add the HTML-based version then progressively enhance it with a SwiftUI-powered one.

We will authenticate the native HTTP request with cookies shared from the web view.

Check out `phase-5` on both repos to begin.

<h2 id="resources">Additional resources</h2>

#### Workshop related

Note that only workshop attendees have access to these codebases.

* [Rails codebase](https://github.com/Turbo-Native-workshop/Rails)
* [iOS codebase](https://github.com/Turbo-Native-workshop/iOS)

#### Official resources

* [Turbo Native documentation](https://github.com/hotwired/turbo-ios/tree/main/Docs)
* [Turbo handbook](https://turbo.hotwired.dev/handbook/introduction)

#### Unofficial resources

* [My 6-part blog series on Turbo Native]({% link turbo-ios.md %})
* [Navigation bar buttons with Turbo Native](https://www.youtube.com/watch?v=vgLIWVWAYrg)

## Thank you!

Thank you again for attending this workshop. I hope you learned enough to get started on your own Turbo Native app!

If you have any questions we didn't cover please email me at [joe@masilotti.com](mailto:joe@masilotti.com) and I'll do my best to help.

You can also find me on Twitter [@joemasilotti](https://twitter.com/joemasilotti) and on my blog, [Masilotti.com]({% link index.html %}).

Please get in touch if you'd like to work together. I have a variety of Turbo Native-related offerings, including:

* **Private, customized workshops** for you team - Best if you want to level up your team and build your own app.
* **Consulting work** – Best if you need an app ASAP and want me to build it.
* **Advisory engagements** – Best if you need support and advice while building an app.

I'm looking forward to hearing from you! 👋
