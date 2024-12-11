---
title: Progressively enhanced Hotwire Native apps in the App Store
date: 2023-02-09
description: Hotwire Native is a game changer for small teams. Here's how folks are leveraging native SDKs to enhance their hybrid apps.
---

[Hotwire Native](https://native.hotwired.dev) is a small framework to build high-fidelity hybrid apps. It renders your Ruby on Rails site inside a native iOS shell, like a tab bar or navigation controller.

Reusing your existing HTML + CSS means you can push an update to your website and your mobile app gets new features for free. All without having to release a new version to the App Store.

This is a game changer for small teams who don’t have a dedicated mobile developer. It lets Rails developers do what they do best: write Ruby code.

And the best part? Really important screens can also be progressively enhanced when needed. Hotwire Native offers hooks to drop down and interact directly with native iOS APIs.

Think native maps, access to the contact book, push notifications, and more. All ways of making your hybrid mobile app feel a little more native.

Here’s how businesses are using Hotwire Native to make high-fidelity mobile apps with native SDK integrations.

## Offline access with Context Travel

![Context Travel in the App Store](/assets/images/progressively-enhanced-turbo-native-apps-in-the-app-store/context-travel.png){:standalone .unstyled}

[Context Travel](https://apps.apple.com/ca/app/context-travel/id1630419856) connects folks with private tours guides around major cities. Their mobile website displays a detailed map with the meeting point to kick off the tour.

But many folks travel without a data plan. So they open their phone and the map won’t load.

I helped Context Travel add offline access to their Hotwire Native app.

On launch it downloads your next 30 days of tours to your device. And if you open the app without an internet connection it automatically switches to offline mode. Here you can view your upcoming tours, the meeting point, and contact information for your guide.

We were able to [launch this feature quickly]({% post_url 2022-07-22-zero-to-app-store-in-7-weeks %}) by making offline access read only. Which means there’s no complicated syncing logic. On app launch it clears out the existing cache and overwrites it with the latest information.

## Instant loading home screens for HEY and Basecamp

![HEY in the App Store](/assets/images/progressively-enhanced-turbo-native-apps-in-the-app-store/hey.png){:standalone .unstyled}

[HEY](https://apps.apple.com/us/app/basecamp-project-management/id1015603248), a new take on email, and [Basecamp](https://apps.apple.com/us/app/basecamp-project-management/id1015603248), a project management tool, are flagship hybrid apps. They are both built by the maintainers of the Hotwire Native library, 37signals.

Opening each of these apps launch fully native home screens. Instantly.

As expected with an email client, HEY immediately loads your latest emails. No network connection required. The team achieves this by caching the JSON response from the server and repopulating the SwiftUI views on launch.

The Basecamp app takes this a step farther with a native tab bar. These five tabs all launch to their own respective native screen, making sure each one loads as quickly as possible.

## Geofencing with BeerMenus

![BeerMenus in the App Store](/assets/images/progressively-enhanced-turbo-native-apps-in-the-app-store/beermenus.png){:standalone .unstyled}

[BeerMenus](https://apps.apple.com/app/apple-store/id917882057) is a popular beer finder app in the North East. Their website helps beer aficionados find rare beer nearby.

A big reason they reached for Hotwire Native is geofencing. When you walk into a BeerMenus establishment you are notified if anything on your “must try” list is available.

We integrated native [region monitoring](https://developer.apple.com/documentation/corelocation/monitoring_the_user_s_proximity_to_geographic_regions) into the iOS app for every bar, restaurant, and bottle shop on BeerMenus. The locations are monitored by the system, which wake up the app when the user crosses a defined boundary.

This means the app doesn’t need to run in the background, saving precious battery life. And the notification is local to the device so it works even without an internet connection.

{% include newsletter/cta.liquid %}

## Native maps for GroupUp

![GroupUp in the App Store](/assets/images/progressively-enhanced-turbo-native-apps-in-the-app-store/groupup.png){:standalone .unstyled}

[GroupUp](https://apps.apple.com/us/app/groupup-find-local-groups/id6444784184?platform=iphone), an app helping folks find and form local groups, heavily relies on panning around a map. An embedded Google Maps or Apple Maps on mobile web still leaves a lot to be desired. The experience might work fine for a single screen but not when it’s the core feature of your product.

GroupUp’s iOS app launches directly to a native map with pins for each group nearby. Tapping a pin kicks off the Hotwire Native integration by rendering the web version of that group’s landing page.

This hybrid approach means GroupUp can focus on the core experience - the map - and leave everything else to the existing HTML and CSS screens rendered from the server.

## Push notifications for RailsDevs

![RailsDevs in the App Store](/assets/images/progressively-enhanced-turbo-native-apps-in-the-app-store/railsdevs.png){:standalone .unstyled}

[RailsDevs](https://apps.apple.com/us/app/railsdevs/id1621607837), a reverse job board for Ruby on Rails developers, is all about communication. Businesses and developers message each other to discuss the role and schedule interviews.

I’m leveraging native push notifications to make sure these messages reach folks as quickly as possible. This cuts down on the response time and moves the conversation along more naturally than having to follow up in an email client.

The push notifications are built on top of [Noticed](https://github.com/excid3/noticed), a Ruby gem that can also coordinate sending emails. This means with one line of code folks receive an email **and** native push.

## Solo dev team for Hauling Buddies

![Hauling Buddies in the App Store](/assets/images/progressively-enhanced-turbo-native-apps-in-the-app-store/hauling-buddies.png){:standalone .unstyled}

[Hauling Buddies](https://apps.apple.com/us/app/hauling-buddies/id6443831303) matches hauling businesses with folks who need to transport their animals.

[Andrew](https://twitter.com/mybuddyandrew), the founder, built and maintains a Rails website, iOS app, _and_ Android app all on his own. He's able to ship across three different platforms because he can focus his time and energy on one thing: the Ruby on Rails website. And let Hotwire Native do the hard work.

## More Hotwire Native apps

The [Turbo Native Directory](https://turbonative.directory) has 40+ Turbo Native and Hotwire Native apps listed on both iOS and Android. Some are even open source!

## Need help with _your_ Hotwire Native app?

I've been working with Hotwire Native for 10+ years and have launched dozens of apps to the App Store. And I'd love to help you confidently launch yours.

I can build and launch your app or level up your team so they can do it on their own. Check out my [services]({% link _pages/services.liquid %}) to see how we can work together.
