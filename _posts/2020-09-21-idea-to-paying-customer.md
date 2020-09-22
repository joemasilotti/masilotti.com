---
layout: post
title: Idea to paying customer in one month
description: A month ago I ran into a problem. One week later I solved it. And three weeks after that I turned it into a (tiny) business.
date: 2020-09-21
image: https://www.mugshotbot.com/m?theme=two_up&image=d33ff6b7&color=green&url=https://masilotti.com/idea-to-paying-customer
permalink: idea-to-paying-customer/
category: masilotti.com
---

A month ago I ran into a problem. One week later I solved it. And three weeks after that I turned it into a (tiny) business.

Here’s how I went from an idea in a notebook to my first paying customer. In 31 days.

{% include timelines/mugshot-bot.html %}

## The problem

It started when I was finishing up a blog post. I had everything ready: the article was proof-read, the code samples were in place, and a gist was uploaded to GitHub.

But I forgot about the social share image. You know, the little preview that pops up when you tweet a link.

I spent *forever* trying to find the perfect stock photo. I tried all the "no design" tools to create one in my browser. Some were OK, a few were good, but most were just plain *generic*.

So I vowed to never waste another second generating these images.

## The idea

What if I could automate all my social share images? Instead of futzing with a tool, just drop a URL on my page and have that generate a decent looking preview.

So I jotted some notes for a MVP. What’s the absolute least I could build to get market validation?

![Notes for Mugshot Bot on August 18, 2020](/images/notebook.jpeg)

If you can’t read my chicken scratch most of those notes touch on three basic pieces of functionality.
1. Scrape a website for the `og:title` and `og:description`
2. Render an HTML view with a fixed design and drop in the scraped content
3. Convert to an image and host it

Turns out, if I kept the scope very narrow I could get something built pretty quickly. And so [Mugshot Bot](https://www.mugshotbot.com?utm_source=masilotti.com) was born.

## `rails new`

Ah, the most exciting part of a project, creating a new app!

I spent the better part of the next few days heads down getting something working. Rails, Active Storage, and `wkhtmlto*` were all key players in being able to build something so quickly.

Having a tiny scope encouraged me to work on only what mattered. There was no pressure to make things look pretty yet, just get it working.

## Launch the MVP

Three days later I had something working. It was ugly and there was no landing page, but it worked.

![v1 of Mugshot Bot](/images/mugshot-bot-v1.jpeg)

I [tweeted](https://twitter.com/joemasilotti/status/1296089448942379008) asking for beta testers and discovered a few folks who were interested in helping. A few DMs later and the images were live on three different blogs!

I also posted to Hacker News with low expectations. But I made it to the top of the second page and generated over 2000 clicks.

## Gather feedback, improve, rinse and repeat

The next two weeks were spent talking to as many people as possible. And asking as many questions as they would answer.

I learned a lot of valuable information, including what to call these little images. Most importantly, people were excited. Turns out I wasn’t the only one running into this problem.

Every feature from here on out has come from (potential) customer feedback. This was an important learning because I usually build things where I'm the only customer.

## Launch customizations

The most requested feature by a long shot was customizations. Bloggers wanted to make their social share images look like their own, with their own branding.

![v2 of Mugshot Bot](/images/mugshot-bot-v2.png)

So I added [Clearance](https://github.com/thoughtbot/clearance) for authentication and launched `/customize`, a single form to change a variety of settings. Now bloggers could change the accent color, the background pattern, and even upload a branded image for one of the themes.

Simple, on purpose. Because that's exactly what folks had asked for.

## First paying customer!

I spent all day Saturday at [Weekend Club](https://www.weekendclub.co?utm_source=masilotti.com), an Indie Hacker accountability community. Even though I had to start early (5am EST!) I was able to finish up the Stripe integration and create a Pro plan for exclusive themes.

I received a ton of valuable feedback throughout the day. Everything from design tweaks to UX pointers to newsletter recommendations. And before the end of the day, **BOOM**! Someone saw enough value in the product to start paying for the Pro features.

## Looking ahead

In no way is this journey complete. Hell, it's only the beginning.

Acquiring a customer is one of the most motivating things I've done since going independent. I've never been more excited about building something.

Watch this space for updates on [Mugshot Bot](https://www.mugshotbot.com?utm_source=masilotti.com) or sign up for my newsletter. Lots more is coming soon!
