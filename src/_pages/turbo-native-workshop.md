---
title: Turbo Native crash course
description: |
  Your quick start guide to Turbo Native on iOS.
permalink: /turbo-native-workshop/

layout: page
image: /images/pages/turbo-native-workshop.png
template_engine: erb

---

<p class="lead"><%= resource.data.description %></p>

<%= render Workshop::CTA.new(newsletter: site.data.newsletters.workshop, event_id: site.config.fathom.events.workshop_ticket, hide_count: true) %>

> "Just wrapped at Joe's first Turbo Native workshop. **Money well spent.** His workshop was huge in helping me wrap some concepts together." - [Mike Monroe](https://twitter.com/mikepmunroe/status/1603513381599715336)

As a Rails developer, Turbo Native is your shortcut to creating native apps. It lets you code once and deploy everywhere, using mobile web views in native frames.

The problem? The official docs are sparse and there aren't many examples out there.

## What you'll get out of this workshop

You'll learn everything you need to know to get started with Turbo Native on iOS:

1.  **How to use Turbo Native** - The steps to integrate the framework into a Xcode project.
1.  **How to navigate** - Add Turbo Navigator to handle the most important navigation flows.
1.  **How to progressively enhance** - Uncover hidden Rails helpers to work with native.
1.  **How to authenticate users** - Ensure users remain signed in between launches.
1.  **How to add native components** - Use Strada for Swift components driven by HTML.

> "Great pace and content, and opportunity to get clarification on some key concepts real time was priceless. **Highly recommended**!" 💯 - [Miles](https://twitter.com/tapster/status/1681582444707807234)

## Format

The 2-hour session combines live coding with hands-on exercises.

There'll be a short break and a Q&A session at the end.

## Extras

You'll also get:

* **iOS + Rails codebases** - The groundwork for launching your own Turbo Native app.
* **Turbo Native community** - Access to a Discord server to discuss Turbo Native.

## Register

<%= render Workshop::CTA.new(newsletter: site.data.newsletters.workshop, event_id: site.config.fathom.events.workshop_ticket, hide_count: true) %>

> "What we learned in few hours **unlocks the possibilities for us to spin up a mobile app for our users quickly and reliably**." - Sweta Sanghavi

## About the author

I'm Joe, your Turbo Native guide since 2015. I've helped businesses go live on the App Store and I'm excited to share my expertise with you.

Question about the workshop? [Send me an email](mailto:joe@masilotti.com).

## Prerequisites

You need to run Ruby on Rails and Xcode, clone git repos, and know very basic Swift. Brush up on <%= link_to "Swift for Ruby developers", "\_posts/2023-04-25-swift-for-ruby-developers.md" %> if needed.
