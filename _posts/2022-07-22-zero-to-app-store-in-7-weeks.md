---
title: Zero to App Store in 7 weeks
date: 2022-07-22
description: New record! I ported a client’s Ruby on Rails app to iOS and went live in the App Store in 7 weeks.
favorite: true
index: 1
---

I hit a big achievement on Wednesday: shortest time from project kick-off to live in the App Store. I ported a client’s Ruby on Rails app to iOS and we went live in the App Store in 7 short weeks.

Here’s how I did it.

## Turbo Native

[Turbo Native](https://turbo.hotwired.dev/handbook/native), part of [Hotwire](https://hotwired.dev), enables mobile web sites to be embedded into native [iOS](https://github.com/hotwired/turbo-ios) (and [Android](https://github.com/hotwired/turbo-android)) apps. Think of it as rendering your HTML content inside of native “chrome” - like tabs and the navigation bar.

This means you don’t have to recreate every screen in native Swift. You can render your existing web content optimized for small screens. The framework provides a bit of “glue” to keep it all together. Like native page transitions, back buttons, and some snapshot caching.

Using Turbo Native meant that we can leverage all of the existing screens, design decisions, Rails controllers, domain logic, and more. Without having to duplicate anything in Swift. If it works on the web it will work in the app.

![Hotwire - HTML over the wire](/assets/images/zero-to-app-store-in-7-weeks/hotwire.png){:standalone}

## Existing mobile web screens

Before starting the project we made sure the Rails app had a solid mobile web design in place. This enabled us to focus on the core iOS integration instead of fixing HTML/CSS issues.

This included:

* Upgrading to [Rails 7](https://rubyonrails.org/2021/12/15/Rails-7-fulfilling-a-vision)
* Enabling [Turbo Drive](https://turbo.hotwired.dev/handbook/drive)
* Ensuring all [forms work with Turbo](https://turbo.hotwired.dev/handbook/drive#form-submissions)
* Fixing any horizontal scrolling issues
* Small design tweaks for mobile web

## Small surface area

We kept the scope small by focusing on a single side of the existing marketplace. And narrowed the initial screens down to core workflows.

Part of the magic of going hybrid is that new screens can be added without any additional native code. Most of the time without even submitting a new binary to the App Store!

All the client needs to do is update their exiting Rails app and *poof* 💨 the iOS app gets the new content for free.

{% include newsletter/cta.liquid %}

## Jumpstart Pro iOS

My secret weapon – we kicked off the project with my [Jumpstart Pro iOS code template](https://jumpstartrails.com/ios). This is all the knowledge I've accumulated launching Turbo Native apps for multiple clients over the last 10+ years.

Stuff the template took care of so I didn’t have to worry about doing it again:

* Native sign in and registration
* Tab bar remotely configured by a Rails endpoint
* Push notification registration and deep linking
* Copy-paste code for native screens powered by Rails APIs 
* Rails integration guide

The first working build I released to TestFlight took less than 2 weeks. All it took was running the configuration script and copy-pasting some design elements into Xcode.

I also upstream generalized changes into the template when working with clients. Code optimizations, bug fixes, and new features get added at a regular cadence. Everything is extracted from real world situations – just like Rails!

![Jumpstart Pro iOS template](/assets/images/zero-to-app-store-in-7-weeks/jumpstart-pro-ios.png){:standalone}

## Short, async feedback loops

To keep things moving we made sure no issue sat for more than 24 hours. All of the work was done in Basecamp and GitHub – we had less than 4 hours of meetings the entire 7 weeks.

Usually when I work with clients I’m invited to their Slack workspace. This was the first time we did all communication in Basecamp and I have to say, I really enjoyed it!

Something I never noticed was the social pressure of “being online” with Slack. It almost feels like the expectations have become *more* synchronous when on Slack, not less… but that’s a blog post for another day!

## Submitting for review ASAP

The first App Store submission was rejected. The Rails site uses Google Analytics so we needed to integrate the [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency) framework to ask for permission to track users.

I push clients to submit as early as possible to catch situations like this. From my experience, the App Store review team usually responds within 48 hours. But if you need to go back and forth a few times that can quickly add up.

![App Store approval!](/assets/images/zero-to-app-store-in-7-weeks/zero-to-app-store.png){:standalone}

## More on Turbo Native

Want to learn more about how to port your Rails app to iOS with Turbo Native?

I wrote a [6-part blog series on building hybrid iOS apps]({% post_url 2021-05-14-turbo-ios %}). It covers authentication, the JavaScript bridge, push notifications, and more.

I can also build and launch your app or level up your team so they can do it on their own. Check out my [services]({% link _pages/services.liquid %}) to see how we can work together.
