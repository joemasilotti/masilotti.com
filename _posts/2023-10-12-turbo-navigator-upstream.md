---
title: "Turbo Navigator: Gearing up for the merge into turbo-ios"
date: 2023-10-12
description: Turbo Navigator is making progress to merge into turbo-ios, reducing boilerplate code and introducing new features.
---

I'm still coming off the high of Rails World last week. What an amazing experience! 🤩 I'm grateful to Amanda and the rest of the Rails Foundation for giving me an opportunity to [talk about Turbo Native](https://rubyonrails.org/world/agenda/day-2/6-joe-masilotti-se4ssion).

In Amsterdam I spoke with a _ton_ of folks in the community. I even got some time with the other maintainer of Turbo Native, Jay Ohms. And good news... **we are almost ready to upstream [Turbo Navigator](https://github.com/joemasilotti/TurboNavigator) into turbo-ios**!

<div class="note">
  <span class="font-semibold">Update October 15, 2024</span>: Turbo Navigator is now a part of Hotwire Native, the new framework for building mobile apps with Rails: <a href="https://native.hotwired.dev" target="_blank">native.hotwired.dev</a>
</div>

The package handles common navigation flows from configuration that lives on your server. It goes beyond the demo app of pushing screens and presenting modals, covering **15+ different flows**.

![Turbo Navigator demo](/assets/images/turbo-navigator-upstream/turbo-navigator-demo.gif){:standalone}

Turbo Navigator reduces boilerplate code in my Turbo Native apps by _at least_ a few hundred lines. And it’s always the first thing I add when I start a [new project for a client]({% link _pages/services.liquid %}). And I'm excited to share that productivity boost with you!

Here are two recent additions that make it even easier for Rails developers to get started with Turbo Native.

## [PR #51](https://github.com/joemasilotti/TurboNavigator/pull/51)

We improved the developer experience around deciding which view controller to display.

Respond with `.accept` to have the default `VisitableViewController` perform a Turbo Visit. Or cancel the navigation entirely with `.reject`.

And for customizations pass a `UIViewController` instance to `.acceptCustom`! All default routing (modals, dismissing, popping, etc.) will occur on this custom controller.

```swift
extension SceneDelegate: TurboNavigationDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        if proposal.properties["vc"] as? String == "numbers" {
            return .acceptCustom(NumbersController())
        } else if proposal.presentation == .none {
            return .reject
        }
        return .accept
    }
}
```

## [PR #48](https://github.com/joemasilotti/TurboNavigator/pull/48)

Then we made it a bit easier to customize the Turbo `Session`. Which was required for a smoother integration with Strada.

You can now initialize `TurboNavigator` with preconfigured sessions. For example, customize the web view or its configuration so you can attach a JavaScript handler.

```swift
let configuration = WKWebViewConfiguration()
// Customize configuration...
let mainSession = Session(webViewConfiguration: configuration)

let webView = WKWebView()
// Customize web view...
let modalSession = Session(webView: webView)

let navigator = TurboNavigator(
    preconfiguredMainSession: mainSession,
    preconfiguredModalSession: modalSession,
    delegate: self
)
```

Stay up to date with [Turbo Navigator](https://github.com/joemasilotti/TurboNavigator) by watching the repository or giving it a star.

## Turbo Native crash course

Next week I'm hosting a 2-hour live session on Turbo Native for Rails developers.

This is perfect for some guided, hands-on experience working with Turbo Navigator. It will also cover how to integrate Strada to create native components.

Registration closes tomorrow. [Grab your ticket here]({% link _pages/workshop.liquid %}).

[Send me an email](mailto:joe@masilotti.com) if you have any questions – I hope to see you there!
