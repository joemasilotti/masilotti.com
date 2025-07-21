---
title: "Ruby Friends is live on TestFlight — join the beta!"
date: 2025-07-23
description: "240+ Rubyists have already joined. Want to make a new friend next time you say \"hello world\"?"
---

The first public version of the Ruby Friends iOS app is live on TestFlight! You can [join the beta](https://testflight.apple.com/join/pmADah1B) and try it out for yourself.

What's Ruby Friends? Dave Thomas sums it up nicely in his [latest newsletter](https://media.pragprog.com/newsletters/2025-07-17.html):

> You create a profile, and it gives you a URL and a QR code. When you chat with people [at a conference or meetup], they can scan your code to see your profile, and if they want to, they can add you as a friend. And that's it. No posts, no transitive-closures of connections; just you and a list of people who wanted you to remember them.

Think of it like a conference companion that helps turn introductions into friendships. I've been building it in public on [my YouTube channel](https://www.youtube.com/@joemasilotti).

## 100 profiles in 48 hours… now 240 and counting

This blew me away.

Within 48 hours of launch, Ruby Friends hit 100 profiles.

Lucky profile #100? [Erin](https://rubyfriends.app/profiles/FFCZ) - congrats and thanks for being part of this!

Since then, we’ve more than doubled that. As of writing, there are over 240 Ruby Friends using the app. That means more than 240 chances to meet someone new, start a conversation, and reconnect later.

![Ruby Friends admin screen](/assets/images/newsletter/ruby-friends-admin.png){:standalone}

## A peek at the app

Here’s a quick look at what’s live in the current TestFlight beta:

![Ruby Friends app on TestFlight](/assets/images/newsletter/ruby-friends-testflight.png){:standalone .unstyled}

You can create your profile, add other Ruby Friends, and manage your notifications. Super simple - and super early. But it’s already working. Up next? Push notifications, of course!

## Building it live

If you missed it, I started building the iOS app live on stream. We covered:

- Spinning up the iOS app from scratch  
- Adding a native tab bar  
- Wiring up the sign-in flow with Hotwire Native  

You can [watch the full session here](https://www.youtube.com/live/UuONfuzjTfA?si=8xo5nb4xcfVbhlg7).

At first, I tried configuring the tabs after the user signed in. It worked… kind of. But it felt messy. So I tossed it and found something better: swapping the `rootViewController` once the user creates a profile.

At a high level, here's what my `SceneDelegate` is doing. It renders a single `Navigator` on every app launch.

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let navigator = Navigator()
    private let tabBarController = HotwireTabBarController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession ...) {
        window?.rootViewController = navigator.rootViewController
        navigator.start()
    }

    private func didSignIn() {
        if window?.rootViewController != tabBarController {
            window?.rootViewController = tabBarController
        }
    }
}
```

And when the user signs in, a bridge component swaps out the `rootViewController` to the tab bar controller.

```swift
class AuthenticationComponent: BridgeComponent {
    override func onReceive(message: Message) {
        guard let data: MessageData = message.data() else { return }

        if data.profileURL != nil {
            SceneController.didSignIn()
        }
    }
}
```

I’ll dive into that code in the next stream. Come say hi!

<iframe class="w-full aspect-video" src="https://www.youtube-nocookie.com/embed/i8-1nWPc_OA?si=S1JUHgkGtlq-i4IO" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

---

That’s it for this week.

If you haven’t already, [grab the beta](https://testflight.apple.com/join/pmADah1B), create a profile, and meet a new Ruby Friend. Or two. Or five.

And if you’re enjoying it, forward this to someone you think might like it too. The more the merrier.

P.S. If you're organizing a Ruby conference, then let me know! Maybe we can get some Ruby Friends QR codes printed on the badges.
