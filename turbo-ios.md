---
layout: post
title: Hybrid iOS apps with Turbo
permalink: turbo-ios/
description: How to build hybrid iOS apps with Turbo and Ruby on Rails. An ongoing series covering authentication, the JavaScript bridge, architecture, and more.
image: https://mugshotbot.com/m?theme=two_up&mode=dark&color=yellow&pattern=lines_in_motion&image=c5e5335e&url=https://masilotti.com/turbo-ios/

---

Native apps are hard. They are expensive to build and even more expensive to maintain.

What if that wasn’t the case? What if every time you built a new workflow in your Rails app, your mobile app got that feature *for free*?

This is possible with [Turbo](https://github.com/hotwired/turbo-ios/), a small framework from the geniuses at Basecamp. Follow this series of posts to learn how to build a hybrid iOS app from scratch. All you need is a mobile website powered by Ruby on Rails.

Follow along as we build a hybrid iOS from scratch alongside the supporting Rails code.

## [1. The Turbo framework]({% post_url turbo-ios/2021-02-18-the-turbo-framework %})

This introduction covers the benefits of hybrid apps and how Turbo helps bridge the gap between web and native. It also breaks down the code in the Quick Start guide from the Turbo wiki line by line. A perfect place to start for those new to Turbo or hybrid in general.

## [2. URL routing]({% post_url turbo-ios/2021-02-26-url-routing %})

The second article covers everything related to routing URLs. This includes visit actions (advance vs. replace), path configuration, error handling, and native view controllers. It also touches on how forms work in Turbo iOS and why you might be running into issues with your Rails app.

### Coming soon...

#### 3. Forms and basic authentication

#### 4. The JavaScript bridge

#### 5. Native screens

#### 6. Architecture and coordinators
