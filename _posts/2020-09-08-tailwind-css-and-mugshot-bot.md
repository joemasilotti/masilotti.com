---
title: Tailwind CSS everywhere and a new Masilotti.com product
date: 2020-09-08
description: It’s been a busy month! I’ve gone all in on Tailwind CSS, launched a new product, and started building a newsletter. Here’s what’s been keeping me busy.
---

It’s been a busy month! I’ve gone all in on Tailwind CSS, launched a new product, and started building a newsletter. Here’s what’s been keeping me busy.

## Masilotti.com

I’ve been playing around with [Tailwind CSS](https://tailwindcss.com) for a little while and finally hit that sweet spot in the learning curve where the magic happens. So, obviously, I’ve become completely obsessed with the framework and am rewriting everything.

First to get the Tailwind treatment is this site, Masilotti.com. I tweaked my colors a bit so they aren’t so aggressively lime green, bumped up the font size, and toned down the contrast a bit.  For context, [it took me one weekend to convert my site to Tailwind CSS]({% post_url 2020-07-24-tailwind-css %}).

All the posts should have migrated over but let me know if anything looks off. How? By opening a PR, of course. Because [Masilotti.com is officially open source](https://github.com/joemasilotti/masilotti.com-tailwind)!

It was awesome to see the first PR bump my Lighthouse scores up to a perfect 100. Thanks again [@peterpeterparker](https://github.com/peterpeterparker).

![Perfect 100 scores on Lighthouse](/assets/images/tailwind-css-and-mugshot-bot/lighthouse-100s.png){:standalone}

## TailwindCSS colors in SwiftUI

Keeping tune with my love of Tailwind I open sourced a new micro library, [TailwindCSS-SwiftUI](https://github.com/joemasilotti/TailwindCSS-SwiftUI). Micro because it has a single purpose: add all 100 hand-picked [Tailwind colors](https://tailwindcss.com/docs/customizing-colors#default-color-palette) to your SwiftUI app.

```swift
import TailwindCSS_SwiftUI

// light green
Theme.Color.green200

// dark orange
Theme.Color.orange700
```

I found that I was copy and pasting these for a bunch of different projects so it saves me a few keystrokes every day. And the colors work really well together, so it saves even more time when prototyping.

## [Mugshot Bot](https://www.mugshotbot.com)

I have a confession. I didn’t publish [my last blog post]({% post_url 2020-08-12-test-deep-links-with-ui-testing %}) for a few days because I couldn’t find the _perfect_ stock photo. I eventually settled for something, hit publish, and stepped away.

Then, as per usual, a great idea hit me in the shower. What if I could *automatically* generate social images? And so [Mugshot Bot](https://www.mugshotbot.com) was born.

The tiny service does one thing and does it well: automates social images for your blog. You punch in a URL and out pops an image. It scrapes the `og:title` and `og:description`, picks a color and pattern, and out pops your image.

Here’s an example. I set this page’s  `og:image` to `https://www.mugshotbot.com/m?url=https://masilotti.com/tailwind-css-and-mugshot-bot/` and Mugshot Bot created this image for me.

![Mugshot Bot example image for this post](/assets/images/tailwind-css-and-mugshot-bot/mugshot-bot-example.jpeg){:standalone}

I don't even have to download the image as it is hosted on S3 automatically. Which means I can automate images for my entire site in like five minutes.

Up next are customizations, dark mode, and premium templates.

## Coming soon…

I’m planning on releasing little updates like this every couple of weeks. I’d love to hear if this was interesting and if you want to learn more. Let me know what you think by sending me a message on Twitter or an email.
