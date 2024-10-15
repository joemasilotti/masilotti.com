---
title: Call Swift APIs from Stimulus in Turbo Native
date: 2023-06-27
description: Wire up your iOS app to call Swift code from events triggered in Stimulus controllers, like native share sheets, push notifications, and more.
---

<div class="note">
  <span class="font-semibold">Update October 15, 2024</span>: Bridge components are now the recommended way to handle JavaScript interactions like this: <a href="https://native.hotwired.dev" target="_blank">native.hotwired.dev</a>
</div>

Turbo Native brings your Rails app to iOS without investing a ton of time writing Swift code. The framework renders your existing HTML and sprinkles on native navigation and chrome, like tab bars.

But what if we want to interact with a *native* API, like sending a push notification or reading calendar data? Enter the JavaScript bridge.

This concept, baked directly into `WKWebView`, lets us pass messages back and forth between native code and our web content. **It enables events triggered from Stimulus to call native code in our app.**

## Getting started

Before we dive in I recommend a working Turbo Native iOS app to play with.

If you don’t have one, no worries! Check out my [Turbo Native in 15 minutes video](https://www.youtube.com/watch?v=83wOvrNtZX4). That will get you up to speed and set up with [an example app](https://github.com/joemasilotti/Turbo-Native-demo).

## Script message handlers

We need to set up a handler to listen for JavaScript events. This is the entry point to our iOS code.

First, extend `SceneDelegate` to conform to the `WKScriptMessageHandler` protocol and implement the only required method.

```swift
// SceneDelegate.swift

extension SceneDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received JavaScript message!", message.body)
    }
}
```

Next, tell the web view to pass JavaScript messages to this method. Add the following to `SceneDelegate` or modify your existing instantiation of `Session`.

```swift
// SceneDelegate.swift

private lazy var session: Session = {
    let configuration = WKWebViewConfiguration()
    configuration.userContentController.add(self, name: "nativeApp")
    return Session(webViewConfiguration: configuration)
}()
```

Note that the “nativeApp” name is an arbitrary string that we choose. This is what gets exposed on the web view to fire messages to our app. Any string will do, but I like this one because it conveys the message destination, our native iOS app.

To test this, add a Stimulus controller to your server and wire it up to your root or home screen. This calls into the exposed “hook” from the iOS client to enable passing messages.

```javascript
// app/javascript/controllers/ios_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    window.webkit?.messageHandlers?.nativeApp?.postMessage({
      name: "test"
    })
  }
}
```

```html
<!-- app/views/home/show.html -->

<div data-controller="ios"></div>
```

If all went well we should see the following log to the the Xcode console when the app launches.

```
Received JavaScript message! {
    name = test;
}
```

<p class="note">Note the question marks in the JavaScript code. These ensure no exceptions are raised when run from a non-Turbo Native context.</p>

## Calling native APIs

Now that we have a bridge to connect Stimulus to Swift, let's actually *do* something. We can update our code to present a native share dialog, dynamically populated with the URL currently being visited.

First, tweak our JavaScript and HTML to pass the current page's URL down to the iOS app.

```javascript
// app/javascript/controllers/ios_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  share() {
    window.webkit?.messageHandlers?.nativeApp?.postMessage({
      name: "share",
      url: window.location.href
    })
  }
}
```

```html
<!-- app/views/home/show.html -->

<div data-controller="ios">
  <button type="button" data-action="ios#share">Share</button>
</div>
```

In our iOS code, update the handler to parse out the URL and present the share sheet.

```swift
// SceneDelegate.swift

func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    // Assume the payload is a hash of strings, otherwise noop.
    guard let body = message.body as? [String: String] else { return }

    if let urlString = body["url"], let url = URL(string: urlString) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        navigationController.present(activityViewController, animated: true)
    }
}
```

Clicking the button will now present a native share sheet, complete with the URL of the current page. Pretty neat!

![A native share sheet, triggered from Stimulus](/assets/images/call-swift-from-stimulus-turbo-native/stimulus-to-swift.png){:standalone}

## What’s next?

We can extend this example to work with additional APIs and SDKs.

Remember how we passed the `name` keyword in the JavaScript message? We can switch off of that to perform different actions.

```swift
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard let body = message.body as? [String: String] else { return }

    if body["name"] == "share" {
        // Present a native share sheet.
    } else if body["name"] == "push" {
        // Request push notification permission.
    }
}
```

In a production app I would extract all the individual API/SDK calling to their own classes and leave this switch statement as the only code in the handler.

Want to learn more about Turbo Native? Subscribe to my newsletter below where I share tips like this every week. I hope to see you there!
