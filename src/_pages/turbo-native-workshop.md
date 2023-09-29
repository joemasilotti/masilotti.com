---
title: Turbo Native workshop
description: |
  A 2-hour workshop on building iOS apps with Turbo Native, powered by your Rails
  codebase.
permalink: /turbo-native-workshop/

layout: page
image: /images/pages/turbo-native-workshop.png
template_engine: erb

---

<p class="lead">Learn how to build iOS apps with Turbo Native, powered by your Rails codebase.</p>

Tuesday, October 17 10am-12pm PT on Zoom. $99 per person.

<%= render Workshop::CTA.new(newsletter: site.data.newsletters.workshop, event_id: site.config.fathom.events.workshop_ticket, hide_count: true) %>

> "Just wrapped at Joe's first Turbo Native workshop. **Money well spent.** His workshop was huge in helping me wrap some concepts together." - [Mike Monroe](https://twitter.com/mikepmunroe/status/1603513381599715336)

Native apps are hard. They’re expensive to build and even more expensive to maintain. But with Turbo Native, that’s no longer true.

The framework enables Rails developers like you and me to build high-fidelity hybrid apps with native navigation in a fraction of the time.

Turbo Native unlocks native apps for Rails developers in a way that avoids a maintenance nightmare. Adding a new feature to your Rails app is automatically available to your native apps — no rebuilding or resubmitting needed. And since you’re building mobile web views there’s not another framework or library to learn once you have Turbo Native set up.

The interactive workshop will be 2 hours long. You'll learn how to use the [turbo-ios](https://github.com/hotwired/turbo-ios) adapter to build high-fidelity hybrid apps with native navigation.

## What you'll get out of this workshop

**How to use Turbo Native** - The steps to integrate the framework into a new Xcode project.

**How to navigate** - Add Turbo Navigator to handle the most important navigation flows.

**How to progressively enhance** - Uncover hidden Rails helpers to work with Turbo Native.

**How to authenticate users** - Ensure users remain signed in between launches.

**How to add native components** - Use Strada to build Swift components driven by HTML.

> "Great pace and content, and opportunity to get clarification on some key concepts real time was priceless. **Highly recommended**!" 💯 - [Miles](https://twitter.com/tapster/status/1681582444707807234)

## Resources

A good portion of the workshop is live coding – sometimes I'll be driving and other times you will be given prompts to complete with other attendees. The session will have one break and wrap up with Q&A.

Attendees will also receive:

**iOS + Rails codebases** - Access to private GitHub repositories to work through during the workshop. Together, these build the groundwork for launching your own Turbo Native app.

**Turbo Native community** - A Discord server invitation to discuss Turbo Native and the take home activities with other attendees and myself.

## Register

Tuesday, October 17 10am-12pm PT on Zoom. $99 per person.

<%= render Workshop::CTA.new(newsletter: site.data.newsletters.workshop, event_id: site.config.fathom.events.workshop_ticket, hide_count: true) %>

> "What we learned in few hours **unlocks the possibilities for us to spin up a mobile app for our users quickly and reliably**." - Sweta Sanghavi

## About the author

Hi, I'm Joe! I've been working with Turbo Native since 2015.

I've helped dozens of businesses launch in the App Store. I know the gotchas, trade offs, and best practices. I'm excited to share what I've learned so you can launch your own app with Turbo Native.

Have questions about the workshop? [Send me an email](mailto:joe@masilotti.com).

## Prerequisites

All attendees must be able to run a Ruby on Rails app and Xcode on their machine, clone a git repository, and navigate between git branches/tags.

They must also have a basic understanding of Swift and iOS development. You should be comfortable working with optionals, protocols, delegates, extensions, and UIKit classes like `UIViewController` and `UINavigationController`.

Read through <%= link_to "Swift for Ruby developers", "_posts/2023-04-25-swift-for-ruby-developers.md" %> to get up to speed.
