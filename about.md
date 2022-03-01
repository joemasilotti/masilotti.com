---
layout: page
title: About
description: "The \"Masilotti.com Umbrella\" contains a few different areas of focus: consulting, coaching, and products."
image: https://www.mugshotbot.com/m?color=green&url=https://masilotti.com/about
intro: true
permalink: about/
---

---

The "Masilotti.com Umbrella", as I like to call it, contains a few different areas of focus.

<h2 class="flex items-center">
  <div class="w-8 h-8 text-gray-800 mr-3">
    {% include desktop_computer.svg %}
  </div>
  Consulting
</h2>

First is consulting, where I help teams design, build, test, and deploy their products. Primarily Ruby on Rails sites, native iOS apps, and Turbo-powered (Turbolinks) hybrid mobile apps.

My focus is clean, testable code and integrating into a company as much as possible. Expect to see me in your Slack and weekly meetings!

I also work full stack across all disciplines, tackling anything from Sidekiq background jobs to front-end Stimulus controllers. Or building the JSON API and SwiftUI app in concert.

<h2 class="flex items-center">
  <div class="w-8 h-8 text-gray-800 mr-3">
    {% include academic_cap.svg %}
  </div>
  Coaching
</h2>

Pair programming is the quickest way to level up your development skills. I take this to heart and offer live 1:1 or group coaching in Ruby on Rails and iOS for teams.

These sessions range from teaching SwiftUI to new iOS developers, getting ramped up in the latest Hotwire features, or in-depth code review. Occasionally, I run group sessions on specific topics, like Turbo Native, UI Testing, or Swift mocks.

<h2 class="flex items-center">
  <div class="w-8 h-8 text-gray-800 mr-3">
    {% include sparkles.svg %}
  </div>
  Products
</h2>

<div class="sm:flex">
  <a href="https://railsdevs.com?utm_source=masilotti.com" class="sm:mx-8 flex-shrink-0">
    <img src="/images/railsdevs.png" class="w-full sm:w-32 h-32 object-contain rounded-lg sm:rounded-full p-2" alt="railsdevs" />
  </a>
  <p>My primary focus is <a href="https://railsdevs.com?utm_source=masilotti.com">railsdevs</a>, a reverse job board for Ruby on Rails developers. I built it to make it easier for devs to find their next gig, whether full-time or freelance. Also, it's <a href="https://github.com/joemasilotti/railsdevs.com">open source</a> and contributions are welcome!</p>
</div>

<div class="sm:flex mt-24 sm:mt-0">
  <a href="https://jumpstartrails.com/ios?utm_source=masilotti.com" class="sm:mx-8 sm:order-last flex-shrink-0">
    <img src="/images/jumpstart.png" class="w-full sm:w-32 h-32 object-contain rounded-lg sm:rounded-full bg-gray-100 p-1" alt="Jumpstart Pro for iOS"/>
  </a>
  <p>Somewhere between my <a href="{% link turbo-ios.md %}">tutorial on turbo-ios</a> and hiring me lives <a href="https://jumpstartrails.com/ios?utm_source=masilotti.com">Jumpstart Pro iOS</a>. It's a plug-and-play code template I built with Chris Oliver to quickly port your Rails app to iOS with Turbo Native.</p>
</div>

<div class="sm:flex mt-24 sm:mt-0">
  <a href="https://xwing.app?utm_source=masilotti.com" class="sm:mx-8 flex-shrink-0">
    <img src="/images/x-wing-ai.png" class="w-full sm:w-32 h-32 object-contain rounded-lg sm:rounded-full bg-gray-100 p-1" alt="X-Wing AI"/>
  </a>
  <p>On iOS I run a board game companion app for X-Wing, <a href="https://xwing.app?utm_source=masilotti.com">X-Wing AI</a>. The app simulates a human opponent with a believable yet unpredictable AI. This has been a huge welcome for a game that usually requires at least two people to play!</p>
</div>

<div class="sm:flex">
  <a href="https://www.mugshotbot.com?utm_source=masilotti.com" class="sm:mx-8 sm:order-last flex-shrink-0">
    <img src="/images/mugshot-bot.png" class="w-full sm:w-32 h-32 object-contain rounded-lg sm:rounded-full bg-purple-100 p-2" alt="Mugshot Bot" />
  </a>
  <p>I <a href="{% post_url 2022-01-05-idea-to-sold-in-14-months %}">recently sold Mugshot Bot</a>, a zero effort social image generator. Plug in a URL and it spits out a beautifully designed, perfectly sized image to share on Facebook and Twitter. You can even point your `og:image` tag directly to Mugshot Bot's servers.</p>
</div>

{% include hotwire.html %}
