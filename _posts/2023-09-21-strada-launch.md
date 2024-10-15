---
title: Strada officially launched!
date: 2023-09-21
description: A first look at Strada, the last missing piece of Hotwire. Let's explore how it unlocks native components driven by the web in Turbo Native apps.
---

Yesterday 37signals [officially launched Strada](https://dev.37signals.com/announcing-strada/). After waiting for what feels like forever, I’m excited to finally explore the last missing piece of Hotwire. Let’s dive in!

Strada is an optional add-on for [Turbo Native apps]({% post_url 2021-05-14-turbo-ios %}) that enables native components driven by the web. It unlocks _progressive enhancement_ of individual controls without converting entire screens to native.

<div class="note">
  <span class="font-semibold">Update October 15, 2024</span>: Strada has been renamed to Bridge Components and comes preconfigured in Hotwire Native apps: <a href="https://native.hotwired.dev" target="_blank">native.hotwired.dev</a>
</div>

For example, converting a `<button>` to a `UIBarButtonItem` on iOS or rendering a HTML modal with `ModalBottomSheetLayout` on Android.

It's important to call out that Strada alone doesn't unlock new features for Turbo Native apps. Everything you can do with the framework you could already do before. Albeit with much, much more code.

Strada provides structure and organization to the tangled mess that is the JavaScript bridge. It simplifies and standardizes communication between web and native components, which makes building robust native elements a joy. 🤓

## Strada example

Here’s an example from the [turbo-ios demo](https://github.com/hotwired/turbo-ios/tree/main/Demo) that renders a dialog when tapping a button.

The web `<button>` is rendered inline with the HTML at the bottom of the content. But on iOS, that moves to a native `UIBarButtonItem` placed nicely in the navigation bar.

![Button - HTML on left - Native on right](/assets/images/strada-launch/strada-button.png){:standalone .unstyled}

Tapping the button displays a dialog that’s rendered via HTML. While this looks fine on the web, it feels pretty out of place in an iOS app. Strada replaces it with a `UIActionSheet`, making the experience feel right at home in a native app.

![Dialog - HTML on left - Native on right](/assets/images/strada-launch/strada-dialog.png){:standalone .unstyled}

## How it works

The [documentation](https://strada.hotwired.dev/handbook/how-it-works) includes a guide on how to augment a web form with a native button.

It starts with a `<form>` element in your web app and wires up the Strada component via Stimulus. Then it walks through building the native side on both iOS and Android.

Let’s walk through what each line does and how it relates to the rest of the demo.

{% include newsletter/cta.liquid title="Want to learn more about Turbo Native?" description="Subscribe to my newsletter with a new Turbo Native tip every week. And get first access to my upcoming workshops and book." %}

### HTML

The tutorial starts with the HTML `<form>` and a submit `<button>`. This looks pretty similar to how you would wire up a Stimulus controller, so far.

```html
<form method="post" data-controller="bridge--form"> <!-- 1. -->
  <!-- Form elements... -->

  <!-- 2. -->
  <button
    type="submit"
    data-bridge--form-target="submit"
    data-bridge-title="Submit">
    Submit Form
  </button>
</form>
```

1. A `<form>` element wired up to a Stimulus controller.
2. The `<button>` sets its target and title to pass to the controller.

### JavaScript

The "Stimulus controller" is actually a `BridgeComponent`!

This subclass is where the JavaScript "glue" is written to send and receive messages to the apps. It's an _extension_ of a Stimulus controller and follows a lot of the same conventions, like targets and actions.

```jsx
import { BridgeComponent, BridgeElement } from "@hotwired/strada"

export default class extends BridgeComponent { // 1.
  static component = "form" // 2.
  static targets = ["submit"]

  submitTargetConnected(target) {
    const submitButton = new BridgeElement(target) // 3.
    const submitTitle = submitButton.title

    this.send("connect", {submitTitle}, () => { // 4.
      target.click() // 5.
    })
  }
}
```

1. Not a `Controller` but something very close.
2. This component is identified as `"form"` to the native apps.
3. A [`BridgeElement`](https://strada.hotwired.dev/reference/elements) to access bridge-specific behaviors and elements. 🤩
4. When the `<submit>` button connects send the button title to the app.
5. When the native button is tapped _click_ the HTML `<submit>` button.

I'm very excited about [`BridgeElement`](https://strada.hotwired.dev/reference/elements)! There are a ton of useful attributes like reading the title, checking if the element is disabled, and querying if a CSS class is attached. This will clean up a lot of my existing JavaScript code.

It's also important to shine light on `click()`. Asking the HTML element do its thing means we can reuse existing form submission logic (controller actions, error handling, flash messages, etc.) without having to do anything in native code. 👍

### Swift

The iOS code looks a bit more complicated. Let’s walk though each step one at a time.

```swift
final class FormComponent: BridgeComponent { // 1.
    override class var name: String { "form" } // 2.

    override func onReceive(message: Message) { // 3.
        if message.event == "connect" {
            handleConnectEvent(message: message)
        }
    }

    private func handleConnectEvent(message: Message) { // 4.
        guard let data: MessageData = message.data() else { return }
        configureBarButton(with: data.submitTitle)
    }

    private func configureBarButton(with title: String) { // 5.
        let action = UIAction { _ in
            self.reply(to: "connect") // 6.
        }
        let item = UIBarButtonItem(title: title, primaryAction: action)

        // Display the button in the app bar
    }
}

private extension FormComponent {
    struct MessageData: Decodable { // 7.
        let submitTitle: String
    }
}
```

1. We inherit from `BridgeComponent` which I imagine includes a lot of glue magic.
2. This identifier matches the one from the JavaScript!
3. All received messages must come through this method - here we act on `"connect"`.
4. This plus 7. decodes the payload sent from JavaScript: a title string.
5. Add the `UIBarButton` to the screen.
6. When the button is tapped, let the JavaScript know by replying to `"connect"`.
7. `Decodable` enables conversion from JSON to a Swift object.

All in all, not too much code to get a native submit button for _every form_ on our web app. And the concrete relationship between components helps keep the code well contained.

> **Heads up**: I’ve only just started exploring Strada so some of this might not be 100% correct. If I made a mistake then [please let me know](mailto:joe@masilotti.com)!

## What’s next?

I’m excited to integrate Strada into my Turbo Native apps. The existing bridge is notoriously finicky and this looks like a great answer to the JavaScript spaghetti I’ve been writing. 🍝

Being able to reply *directly* to a message is going to simplify a lot of behavior around native components. And unlock some new behavior that would not have been worth the effort before Strada.

When I return from [Rails World](https://rubyonrails.org/world/agenda/day-2/6-joe-masilotti-se4ssion) I have a lot of work ahead of me! I plan to rewrite the [JavaScript bridge section]({% post_url turbo-ios/2021-04-02-the-javascript-bridge %}) of my turbo-ios tutorial to use Strada. I'd also love to compare and contrast the two approaches [when building a `UIMenu`]({% post_url 2023-07-24-uimenu-turbo-native %}).

And I'll obviously be including an entire chapter (or more) about Strada in my upcoming book on Turbo Native. So many things to do and so little time!
