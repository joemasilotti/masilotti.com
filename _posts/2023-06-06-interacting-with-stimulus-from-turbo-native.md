---
title: Interacting with Stimulus from Turbo Native apps
date: 2023-06-06
description: A low-maintenance approach to interacting with Stimulus controllers from native Swift code.
---

<div class="note">
  <span class="font-semibold">Update October 15, 2024</span>: Bridge components are now the recommended way to handle JavaScript interactions like this: <a href="https://native.hotwired.dev" target="_blank">native.hotwired.dev</a>
</div>

Last week [I asked Twitter what I should write about next](https://twitter.com/joemasilotti/status/1664632478752210944).

And **accessing Stimulus from iOS code** received the most votes - so let’s dive in!

## The JavaScript bridge

In Turbo Native you can use the JavaScript bridge to interact with your server outside of page requests. I mostly use it to manipulate web elements from native code. For example, to [tap a native button to submit a web-based form](https://www.youtube.com/watch?v=vgLIWVWAYrg).

At a high level, you grab a reference to your Turbo Session and evaluate JavaScript directly on the web view. Here’s how to change the background color of the HTML from Swift.

```swift
session.webView.evaluateJavaScript("document.body.style.background = 'orange';")
```

There’s more information on the bridge in the [official documentation](https://github.com/hotwired/turbo-ios/blob/main/Docs/Advanced.md#native---javascript-integration). And for more practical examples, check out [my introduction to the JavaScript bridge]({% post_url turbo-ios/2021-04-02-the-javascript-bridge %}).

## Enter Stimulus

A Stimulus controller I frequently see toggles a menu when a button is tapped. Hamburger menu, slide-in menu, three-line menu… whatever you call it, there’s a good chance your app has one!

```html
<div data-controller="toggle">
  <button id="menu-button" type="button" data-action="toggle#toggle">Toggle</button>
  <p id="menu" data-toggle-target="content" class="hidden">Now you can see me!</p>
</div>
```

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

To trigger this interaction from iOS we can duplicate the display logic in JavaScript.

```swift
let script = "document.querySelector('#menu').classList.toggle('hidden');"
session.webView.evaluateJavaScript(script)
```

But this is brittle. If the ID of the element changes we won’t find our target. And what if we want to slide the menu off the screen instead hiding it? We would need to release a new version of our iOS app to support either of these updates.

## Low maintenance interaction

Instead, we ignore the fact that Stimulus exists entirely. This is an implementation detail - and one we don’t want to be dependent on.

Here we interact with the user-visible element instead, the button, and click it.

```swift
let script = "document.querySelector('#menu-button').click()';"
session.webView.evaluateJavaScript(script)
```

As long as that button and ID render on the page the correct behavior will continue to work. And no update to the App Store is required!

I also recommend adding a system-level test that evaluates this same JavaScript from your *Rails* test suite. This helps ensure the ID remains even when it might not be accessed in the Rails codebase.

This approach keeps our iOS app decoupled from our Stimulus controller and makes it behave more like a real user. And going through the App Store review process one less time makes me a happy developer!
