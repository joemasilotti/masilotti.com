---
title: "RailsConf inspired me to build something new"
date: 2025-07-15
description: "Reflecting on RailsConf chats, building Ruby Friends, and learning new things in the Ruby community!"
---

Last week I attended the last RailsConf ever. A bittersweet moment, since the conference has been such an integral part of the Ruby community for the last 20 years.

But the 800+ attendees brought an energy I've never seen before at a code-related meetup. And it was infectious. So much so, that I too decided to build something new. More on that below. 😉

## The hallway track

![Small notebook, big ideas](/assets/images/inspired-by-railsconf/tiny-notebook.jpeg){:standalone}

Over the three days in Philadelphia I kept track of everyone I spoke with on my tiny little notebook. Here are some of the conversations that stood out.

- [Adrian Marin](https://adrianthedev.com) – We talked about the challenge of pricing developer-focused tools. His work on [Avo](https://avohq.io) gave me a lot of ideas for how to improve the team licensing model for [Bridge Components]({% link _pages/bridge-components.liquid %}). I walked away thinking I should make it easier to buy for teams and double down on screencasts.
- [Camila](https://www.linkedin.com/in/camilacsouza/) and [Eduardo](https://www.linkedin.com/in/eduardogsouza/) Souza – Easily one of the highlights of the conference. Camila launched a production-ready iOS app **in just two weeks** after reading my book - with no prior Swift or Kotlin experience. I loved hearing about how it went live in the App Store and their experience going all-in on Hotwire Native.
- [Andy Atkinson](https://andyatkinson.com) – Like myself, Andy is also a consultant and Pragmatic Bookshelf author ([High Performance PostgreSQL for Rails](https://andyatkinson.com/pgrailsbook)). We jammed on an idea for a book club that would meet weekly for two months or so. It could be a great way to combine our love of writing with our consulting businesses. We also swapped tips on how to promote our books and find new clients.

## Teaching Hotwire Native at RailsConf

![Joe Masilotti presents at RailsConf 2025](/assets/images/inspired-by-railsconf/workshop.jpeg){:standalone}

On Wednesday I hosted a two-hour workshop teaching Hotwire Native from scratch. Every seat was full and folks were sitting on the floor! Together we:

- Took a plain old Rails app and brought it to iOS and Android
- Added native tab navigation
- Built a custom iOS bridge component

I also forgot how to delete a record in Rails. 😪 Luckily, the audience helped me out.

As promised, here's links to the [slides]({% link _pages/slides/railsconf-2025.liquid %}) and all of the [code](https://github.com/joemasilotti/railsconf-2025-code) we wrote together.

## Talks that sparked new ideas

![AuthN vs. AuthZ slide from Alicia Rojas talk at RailsConf 2025](/assets/images/inspired-by-railsconf/authn-vs-authz.jpeg){:standalone}

RailsConf wasn't just socializing and teaching. I also learned a ton from the talks. Here are two that really stuck out.

### Unraveling The Black Box: Past, Present And Future Of Authentication In Rails
    
Alicia Rojas gave the clearest explanation I've ever heard of the difference between authentication and authorization. If you've ever confused AuthN with AuthZ, here's a definitive answer.
    
### The Future Of: PWAs On Rails
    
Edy Silva's talk lit a fire under me. As I watched, I wondered: *could I get this working in a Hotwire Native app?* After the talk I opened my laptop and two hours later had offline access working natively. I'll share a full write-up soon - this could be *huge* for Hotwire Native.

## Announcing: Ruby Friends

![What is your favorite part of RailsConf?](/assets/images/inspired-by-railsconf/favorite-part-of-railsconf.jpeg){:standalone .max-w-sm}

One thing I heard over and over again at RailsConf: "I love meeting people at conferences, but I always forget who I talked to once I get home."

Same here. So I'm building something new: [RubyFriends.app](https://rubyfriends.app)

It's a simple site (and soon-to-be app) that helps you:

- Meet someone new at a Ruby event
- Spark a real conversation
- Reconnect later

Think of it like a conference companion that helps turn introductions into friendships. I'm building it in public and starting development of the Hotwire Native app this week.

This Thursday at 11am PT I'll be live coding the Hotwire Native integration on YouTube. Come hang out, ask questions, and see how it all comes together.

{% include embeds/youtube.liquid id="UuONfuzjTfA" %}

## What are you building?

RailsConf left me feeling fired up and full of ideas. I'm grateful to everyone I talked to and learned from last week.

Now I want to hear from you: **What are you building next?**

Reply to this email and let me know - I'd love to check it out!
