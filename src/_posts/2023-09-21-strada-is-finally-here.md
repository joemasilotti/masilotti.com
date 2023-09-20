---
title: Strada is finally here!
date: 2023-09-21
description: |
  A first look at Strada – unlock native components driven by the web in Turbo
  Native apps.
permalink: /strada-is-finally-here/
---

# Strada is finally here!

Yesterday 37signals [officially launched Strada](https://dev.37signals.com/announcing-strada/). After waiting for what feels like forever, I’m excited to finally explore the latest component of Hotwire. Let’s dive in!

Strada is an optional add-on for Turbo Native apps that enables native components driven by the web. It unlocks _progressive enhancement_ of individual controls without converting entire screens to native.

## Strada example

Here’s an example from the [turbo-ios demo](https://github.com/hotwired/turbo-ios/tree/main/Demo) that renders a dialog when tapping a button.

The web `<button>` is rendered inline with the HTML at the bottom of the content. But on iOS, that moves to a native `UIBarButtonItem` placed nicely in the navigation bar.

![Button - HTML on left - Native on right](/images/strada-button.png){:standalone}

Tapping the button displays a dialog that’s rendered via HTML. While this looks fine on the web, it feels pretty out of place in an iOS app. Strada replaces it with a `UIActionSheet`, making the experience feel right at home in a native app.

![Dialog - HTML on left - Native on right](/images/strada-dialog.png){:standalone}

To add this to your app you have to write some JavaScript glue and the native Swift/Kotlin code to render the dialog. Strada doesn't build the native components for you – it provides the tools to make it easier to do so.

## How it works

The [documentation](https://strada.hotwired.dev/handbook/how-it-works) includes a guide on how to augment a web form with a native button.

It starts with a `<form>` element in your web app and wires up the Strada component via Stimulus. Then it walks through building the native side on both iOS and Android.

A `BridgeComponent` subclass is where you write the JavaScript “glue” to send and receive messages to the apps. This is an extension of a Stimulus controller and follows a lot of the same conventions.

Let’s walk through what each line does and how it relates to the rest of the demo.

### HTML

We start with the HTML `<form>` and a submit `<button>`.

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

The Stimulus controller is actually a `BridgeComponent`!

```jsx
import { BridgeComponent, BridgeElement } from "@hotwired/strada"

export default class extends BridgeComponent {
  static component = "form" // 1.
  static targets = ["submit"]

  submitTargetConnected(target) {
    const submitButton = new BridgeElement(target)
    const submitTitle = submitButton.title

    this.send("connect", {submitTitle}, () => { // 2.
      target.click() // 3.
    })
  }
}
```

1. This component is identified as `"form"` to the native apps.
2. When the `<submit>` button connects send the button title to the app.
3. When the native button is tapped _click_ the HTML `<submit>` button.

This last part is key. We reuse our existing form submission logic (controller actions, error handling, flash messages, etc.) without having to do anything in native code.

### Swift

The iOS code looks a bit more complicated. Let’s walk though each function one-by-one.

```swift
final class FormComponent: BridgeComponent { // 1.
    override class var name: String { "form" } // 2.

    override func onReceive(message: Message) { // 3.
        switch message.event {
        case "connect":
            handleConnectEvent(message: message)
        }
    }

    private func handleConnectEvent(message: Message) { // 4.
        guard let data: MessageData = message.data() else { return }
        configureBarButton(with: data.submitTitle)
    }

    private func configureBarButton(with title: String) { // 5.
        let item = UIBarButtonItem(title: title,
                                   style: .plain,
                                   target: self,
                                   action: #selector(performAction))

        // Display the button in the app bar
    }

    @objc func performAction() { // 6.
        reply(to: "connect")
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
4. This plus 7. decodes the payload sent from JavaScript - a title string.
5. Add the `UIBarButton` to the screen. Fire `performAction()` when tapped.
6. When the button is tapped, let the JavaScript know by replying to `"connect"`.
7. `Decodable` enables conversion from JSON to a Swift object.

All in all, not too much code to get a native submit button for every form on our web app. And the concrete relationship between components helps keep the code well contained.

> I’ve only just started exploring Strada so some of this might not be 100% correct. If I made a mistake then [please let me know](mailto:joe@masilotti.com)!

## What’s next?

I’m excited to start working Strada into my Turbo Native apps. The JavaScript bridge is notoriously finicky and this looks like a great answer to the spaghetti code I’ve been writing for a while.

Being able to reply *directly* to a message is going to simplify a lot of behavior around native components.

When I return from [Rails World](https://rubyonrails.org/world/agenda/day-2/6-joe-masilotti-se4ssion) I have a lot of work ahead of me! I want to rewrite the [JavaScript bridge section of my turbo-ios tutorial]({% post_url 2021-05-14-turbo-ios %}) to use Strada. I also want to compare the two approaches [for building a `UIMenu`]({% post_url 2023-07-24-uimenu-turbo-native %}).
