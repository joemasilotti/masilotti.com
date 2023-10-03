---
title: Turbo Native crash course
description: |
  Everything you need to know to get started with Turbo Native on iOS in 2 hours.
permalink: /turbo-native-workshop/

layout: page
image: /images/pages/turbo-native-workshop.png
template_engine: erb

---

<p class="lead">Everything you need to know to get started with Turbo Native on iOS.</p>

Tuesday, October 17 at 10am-12pm PT on Zoom. $99 per person.

<%= render Workshop::CTA.new(newsletter: site.data.newsletters.workshop, event_id: site.config.fathom.events.workshop_ticket, hide_count: true) %>

> "Just wrapped at Joe's first Turbo Native workshop. **Money well spent.** His workshop was huge in helping me wrap some concepts together." - [Mike Monroe](https://twitter.com/mikepmunroe/status/1603513381599715336)

Turbo Native is a Rails developer's secret weapon. It enables us to launch native apps in a fraction of the time. It is a true _write once deploy anywhere_ framework, rendering mobile web views inside native chrome.

But getting started isn't easy. The documentation leaves a lot to be desired. Outside of the demo app there aren't a lot of examples to follow.

This crash course will teach you everything you need to know to get started with Turbo Native on iOS.

## What you'll get out of this workshop

1.  **How to use Turbo Native** - The steps to integrate the framework into a Xcode project.
1.  **How to navigate** - Add Turbo Navigator to handle the most important navigation flows.
1.  **How to progressively enhance** - Uncover hidden Rails helpers to work with native.
1.  **How to authenticate users** - Ensure users remain signed in between launches.
1.  **How to add native components** - Use Strada for Swift components driven by HTML.

> "Great pace and content, and opportunity to get clarification on some key concepts real time was priceless. **Highly recommended**!" 💯 - [Miles](https://twitter.com/tapster/status/1681582444707807234)

## Resources

A good portion of the workshop is live coding – sometimes I'll be driving and other times you will be given prompts to complete with other attendees. The session will have one break and wrap up with Q&A.

Attendees will also receive:

* **iOS + Rails codebases** - Access to private GitHub repositories to work through during the workshop. Together, these build the groundwork for launching your own Turbo Native app.
* **Turbo Native community** - A Discord server invitation to discuss Turbo Native and the take home activities with other attendees and myself.

## Register

Tuesday, October 17 at 10am-12pm PT on Zoom. $99 per person.

<%= render Workshop::CTA.new(newsletter: site.data.newsletters.workshop, event_id: site.config.fathom.events.workshop_ticket, hide_count: true) %>

> "What we learned in few hours **unlocks the possibilities for us to spin up a mobile app for our users quickly and reliably**." - Sweta Sanghavi

## About the author

Hi, I'm Joe! I've been working with Turbo Native since 2015.

I've helped dozens of businesses launch in the App Store. I know the gotchas, trade offs, and best practices. I'm excited to share what I've learned so you can launch your own app with Turbo Native.

Have questions about the workshop? [Send me an email](mailto:joe@masilotti.com).

## Prerequisites

All attendees must be able to run a Ruby on Rails app and Xcode on their machine, clone a git repository, and navigate between git branches/tags.

You must also have a basic understanding of Swift. Read through <%= link_to "Swift for Ruby developers", "\_posts/2023-04-25-swift-for-ruby-developers.md" %> to get up to speed.
