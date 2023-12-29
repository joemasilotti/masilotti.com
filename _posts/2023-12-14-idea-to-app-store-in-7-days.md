---
title: Idea to App Store in 7 days
date: 2023-12-14
description: The story of Daily Log, a web and iOS app that I built and launched to the App Store in 7 days.
---

Last week I started a new project to scratch an itch. Something simple but useful. And in just **7 days** I launched a web and iOS app to the App Store. Here’s the story of [Daily Log](https://dailylog.ing).

---

I’ve been using Apple Notes to keep track of some important “metrics” throughout my day. But keeping everything in a single _huge_ Apple Note quickly got unwieldy.

So I decided to build a simple but useful app to help me track my exercise, how much water I drink, what I eat, and the medications and supplements I take.

## Information flow

My first step was laying out the overall design and how data flows through the app.

Having tracked these metrics for a while I knew that the most important view is seeing today’s logs. Looking at what I’ve eaten earlier in the day helps me make better decisions when dinner time roles around.

I sketched out a basic design for desktop and mobile on paper. And after a little tinkering I started copy-pasting in some Tailwind UI components. It’s mind-blowing how quickly this started to look like a real app. Especially considering it's just HTML with Tailwind CSS classes!

![Desktop mockup of Daily Log](/assets/images/idea-to-app-store-in-7-days/desktop-screenshot.png){:standalone}

![Mobile mockups of Daily Log](/assets/images/idea-to-app-store-in-7-days/mobile-screenshot.png){:standalone}

## Ruby on Rails app

With the core of the design done I started to convert these screens into ERB views. I created a new Ruby on Rails app and wired up some static screens.

I took care to extract repeating entries into component-like view partials. This helped a ton as I could tweak individual elements, like the layout of the button, without having to re-apply changes across multiple files. It also helped set up the initial view composition when the views became more dynamic.

From there I created a few migrations to set up the initial database tables, one for each entry type: exercise, medication, water, and food. I wasn’t sure if this project would ever be public so I didn’t even set up a user model or authentication!

With the database in place it was relatively quick to create the models and controllers to handle adding new entries. And it wasn’t before long that I had a fully functioning web app.

## iOS app

After building the core functionally into the web I switched gears to focus on iOS.

To move as quickly as possible I opted for a hybrid app powered by [Turbo Native](https://github.com/hotwired/turbo-ios). This “wraps” the web content in some chrome, providing native navigation between screens. It meant I could keep _all_ of my business logic in the Rails app leaving a relatively thin iOS client.

The first iteration was only 20 lines of code!

![Initial iOS code for Daily Log](/assets/images/idea-to-app-store-in-7-days/xcode.png){:standalone}

<p class="note">Want to learn more about Turbo Native? Here's my <a href="https://www.youtube.com/watch?v=hAq05KSra2g">30 minute talk from Rails World</a> on how to get started.</p>

## More features

With the core of the web and iOS apps built I worked through some features to make it more of a Real Thing™.

First up was adding users and authentication to make sure folks besides me could actually use it. I also encrypted all entries and email addresses, medication and such being fairly sensitive information.

I also added buttons to navigate between different days. I’ve found this useful to get an idea of what I ate or did yesterday, especially if I got a work out in. To make these work on iOS I used Strada to add _native_ buttons to the navigation bar at the top.

App Store Review Guideline [4.2](https://developer.apple.com/app-store/review/guidelines/#minimum-functionality) states that "Your app should include features, content, and UI that elevate it beyond a repackaged website." I knew from [my App Store submission tips]({% post_url 2023-08-14-turbo-native-app-store-tips %}) that a great way to address this is with a native control or two.

![Native buttons via Strada](/assets/images/idea-to-app-store-in-7-days/strada.png){:standalone .unstyled}

I wrapped up by adding a few settings so folks can choose between imperial and metric systems, change their time zone, and delete their account.

## App Store release

I had a few folks using the app on TestFlight and didn’t see any issues pop up. So I figured it would be a good time to submit to the App Store - less features means less potential bugs!

But Apple was not happy. They didn’t like the idea that you needed an account.

![Screenshot of App Store review](/assets/images/idea-to-app-store-in-7-days/app-store-review.png){:standalone}

I found myself in a weird situation. There isn’t _anything_ someone can do in the app without an account. Should I try and explain that to them? Or give in and add a new feature for folks that haven’t signed up yet?

I decided to clearly explain that you need an account to use the app and that there’s no way around it. To my surprise, a few hours later the app was approved and live in the [App Store](https://apps.apple.com/us/app/daily-log-app/id6473819686)!

## Open source

I saved the best for last… **the entire codebase is open source!**

Every line of Ruby and Swift that powers the web and iOS app can be viewed on [GitHub](https://github.com/joemasilotti/daily-log).

There are so few (zero?) open source Turbo Native apps in the wild. So I’m really excited to have this as an example to point people to. Especially because it includes the full picture: a live Rails app and an iOS app in the App Store.

## Building in public

I’m going to continue to update Daily Log with new features and native integrations. Follow me [on Twitter](https://twitter.com/joemasilotti) to stay up to date with the day-to-day changes.

Next week I’m doing a video breakdown of the entire codebase for [my newsletter]({% link _pages/newsletter.liquid %}). I’ll walk through how the Rails code integrates with the iOS app and how the native components work. The hand-rolled authentication strategy is another topic I’d love to explore.

If you try Daily Log then let me know what you think [via email](mailto:joe@masilotti.com). I'd love to hear from you!
