---
title: App Store submission tips for Hotwire Native apps
date: 2023-08-14
description: The App Store Review Guidelines to watch out for when submitting your own Hotwire Native app to the App Store.
---

Last week, one of my client’s [Hotwire Native]({% post_url 2021-05-14-turbo-ios %}) apps was approved for sale in the App Store. It took a few back-and-forths with the Apple review team, but after 3 weeks we finally made it!

![Hotwire Native app version 1.0 approved!](/assets/images/turbo-native-app-store-tips/app-store-approval-notification.jpeg){:standalone}

The good news is that most of the issues could have been avoided with our first submission. Here are some [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) to watch out for when submitting your own Hotwire Native app to the App Store.

## [4.2 Minimum Functionality](https://developer.apple.com/app-store/review/guidelines/#4.2)

> Your app should include features, content, and UI that **elevate it beyond a repackaged website**…

4.2 is by far the most important guideline to consider when building a Hotwire Native app. You will most likely _not_ get accepted if you repackage your Rails app in some native chrome.

It needs something more to warrant an app. Ideally something unique to the platform, like a native feature or two.

I usually reach for a [native tab bar]({% post_url 2023-08-07-turbo-native-tabs %}) or push notifications. These are not especially difficult to add on top of a barebones Hotwire Native app. But they go a long way in making it feel way more native.

Another option is to replace your web-based hamburger menu with a [native `UIMenu`]({% post_url 2023-07-24-uimenu-turbo-native %}). This is a bit more work than a tab bar, yes. But it does look really good!

![UIMenu demo](/assets/images/turbo-native-app-store-tips/uimenu-demo.gif){:standalone}

## [2.1 - Performance - App Completeness](https://developer.apple.com/app-store/review/guidelines/#2.1)

> Submissions to App Review, including apps you make available for pre-order, should be final versions… **Make sure your app has been tested on-device for bugs and stability before you submit it**, and include demo account info (and turn on your back-end service!) if your app includes a login… **We will reject incomplete app bundles and binaries that crash** or exhibit obvious technical problems.

In short, don’t submit an app that crashes.

A common and easily overlooked crash occurs when accessing the camera or photo library. For example, a web form that accepts files via `<input type="file">`.

When accessed in the web view that powers Hotwire Native, we need to ask the user for permission first. Otherwise, the app will crash. Lucky for us, it’s a two-liner!

Set [`NSCameraUsageDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription) and [`NSPhotoLibraryUsageDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nsphotolibraryusagedescription) to request access to the user’s camera and photo library, respectively. These can be set in the `Info.plist` file in your Xcode project.

Make sure to set the description to something that makes sense for your app. More information on what, and why, can be found in [the docs](https://developer.apple.com/documentation/photokit/delivering_an_enhanced_privacy_experience_in_your_photos_app).

![Info.plist](/assets/images/turbo-native-app-store-tips/info.plist.png){:standalone}

## [Guideline 5.1.1(v) - Data Collection and Storage](https://developer.apple.com/app-store/review/guidelines/#5.1.1v)

> If your app doesn’t include significant account-based features, let people use it without a login. **If your app supports account creation, you must also offer account deletion within the app…**

A rather new requirement that was added in June 2022. And one that I forget more often than I care to admit.

The [guidelines](https://developer.apple.com/support/offering-account-deletion-in-your-app/) include making the account deletion option easy to find in your app and offering to delete the entire account record, along with associated personal data.

For Hotwire Native apps, I treat this interaction the same as when someone signs out. But instead of sending `DELETE` to `/sessions`, it goes to `/users`. The actual account deletion all occurs on the server side.

## [3.1.3(b) Multiplatform Services](https://developer.apple.com/app-store/review/guidelines/#3.1.3b)

> Apps that operate across multiple platforms may allow users to access content, subscriptions, or features they have acquired in your app on other platforms or your web site, including consumable items in multi-platform games, **provided those items are also available as in-app purchases within the app**.

No one wants to give Apple 15% to 30% of their revenue. I get it. But sometimes its easier to play by the rules then try to find workarounds.

I recommend that you should add in-app purchases to your app if:

* A potential customer can pay you _directly_ for your service **and**
* they can do so via a self-serve interaction.

But with all of your business logic on the server, it can be tough to coordinate permissions on the client. To help with this I reach for [RevenueCat](https://www.revenuecat.com).

The RevenueCat SDK simplifies the in-app purchase flow dramatically. And it sends your server a webhook for each subscription change. The only responsibility the client app has is to initiate the purchase screen. Everything else is handled via RevenueCat and your server.

Also, please note that there are _many_ rules and exceptions regarding in-app purchases! I recommend reading and understanding all of [3.1 Payments](https://developer.apple.com/app-store/review/guidelines/#payments) before deciding if an iOS app is the right fit for your business. Or, [book a call](https://savvycal.com/joemasilotti/47ee5e7d) and we can chat.

### [2.3.2](https://developer.apple.com/app-store/review/guidelines/#2.3.2)

> If your app includes in-app purchases, make sure your app description, screenshots, and previews **clearly indicate whether any featured items, levels, subscriptions, etc. require additional purchases**.

Here’s another note if you decide to add in-app purchases to your app. I recently had an app rejected because the App Store description mentioned premium features without indicating they were paid.

The fix was a quick copy change done in App Store Connect. But if possible, I’d avoid this next time by reviewing the metadata before submitting.

### Paid Applications agreement

Apps with in-app purchases will also need to comply with the Paid Applications agreement. An active Apple developer account is required for access, so I won’t quote directly.

Here are a few notes I’ve forgotten and have had apps rejected for in the past:

- Include a link to the Terms of Use (EULA) in the app binary
- Include a link to the Terms of Use (EULA) in the app _metadata_
- Include a link to the privacy policy in the app binary

## Need some extra help?

I’ve picked up these tips first hand, helping dozens of folks launch their Hotwire Native apps in the App Store. But the process can be overwhelming to someone who is new to the Apple ecosystem.

If you’re thinking of launching an iOS app then [get in touch]({% link _pages/services.liquid %}). I offer everything from 1:1 advisory calls, leveling up your team, and building full apps. I’d love to help you launch your Rails app in the App Store with Hotwire Native!
