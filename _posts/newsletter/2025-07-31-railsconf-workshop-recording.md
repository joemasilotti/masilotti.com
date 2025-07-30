---
title: "RailsConf workshop recording and Ruby Friends v1.2"
date: 2025-07-31
description: "Hotwire Native workshop recording, new bridge component tutorial, and Ruby Friends v1.2 with QR scanning, Universal Links, push, and Wallet integration."
---

Hey everyone, how’s your week going?

Last night we took the boys to dinner at a local family-friendly brewery. And it was *glorious*.

Why don’t more places like this exist?! Crayons, french fries, a play area, beer… it’s a busy parent’s dream!

![Joe with his boys at a family-friendly brewery](/assets/images/newsletter/joe-with-kids-at-brewery.jpeg){:standalone}

## RailsConf workshop recording

If you missed my Hotwire Native workshop at RailsConf then don’t fret, the [recording is now on YouTube](https://youtu.be/gIOkC44_dA8). When you finish working through it then hit reply and show me what you built!

{% include embeds/youtube.liquid id="gIOkC44_dA8" %}

Ruby Central also uploaded recordings of the rest of the [talks and workshops](https://www.youtube.com/playlist?list=PLbHJudTY1K0fOQPBF0uTwFIGuMVEKnV1p). I’m excited to catch up on these talks that I missed while in Philadelphia:

- [Validating non-model classes with…ActiveModel? by Andy Andrea](https://youtu.be/4JiNCgPn5HY)
- [Cache = Cash! 2.0 by Stefan Wintermeyer](https://youtu.be/MVHfdblm7uU)
- [An ActiveRecord Rewrite: the Story Behind the Attributes API by Tess Griffin](https://youtu.be/HMqbBno22_s)

When I got back from the conference, I finally recorded a Hotwire Native video I’d been excited to make for a while.

## Add a native button to your Hotwire Native app

This 5 minute tutorial walks you through how to copy and paste a ready-made bridge component from my open-source library. No Swift or Kotlin required!

{% include embeds/youtube.liquid id="HMMkYi2_ZNk" %}

I’m thinking about doing a short video like this for each component. Would that be helpful?

Speaking of bridge components, I used the [Barcode Scanner](https://github.com/joemasilotti/bridge-components/tree/main/components/barcode-scanner) and [Notification Token](https://github.com/joemasilotti/bridge-components/tree/main/components/notification-token) components for the latest iOS release of Ruby Friends!

## Ruby Friends v1.2

[Ruby Friends](https://rubyfriends.app), a fun little app to help you keep in touch with folks you meet at conferences, just hit v1.2 on iOS.

This release includes a *ton* of new native features:

- **QR code scanning** with a native bridge component
- **Push notifications** when someone adds you as a friend
- **Universal Links** to jump into the app from emails and messages
- **Apple Wallet support** with *Add to Wallet* integration
- **Mastodon** profile links

I’m also working on an NFC integration. This would enable tapping a NFC tag and deep linking right to a profile… even if the app isn’t running! I have a proof-of-concept working and just need to iron out some bugs.

![The Ruby Friends iOS app reading an NFC tag](/assets/images/newsletter/ruby-friends-nfc-scan.png){:standalone .unstyled}

There's probably a generic component that I can extract from this and add to my [bridge component library](https://bridgecomponents.dev), too.

Want to give it a try? Hit reply and I'll add you to the TestFlight group.

Until next time, folks!
