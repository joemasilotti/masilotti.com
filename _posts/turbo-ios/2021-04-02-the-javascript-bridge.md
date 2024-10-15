---
title: "Hybrid iOS apps with Turbo – Part 4: The JavaScript bridge"
date: 2021-04-02
description: The JavaScript bridge is the intersection of client and server. It enables passing messages between the two worlds without waiting for someone to tap a link.
series: turbo-ios
series_title: The JavaScript bridge
---

{% include warning.liquid %}

This is part 4 of a 6 part series on building hybrid iOS apps with Turbo. Parts 1 through 3 built us an "out of the box" hybrid app with [navigation]({% post_url turbo-ios/2021-02-18-hybrid-apps-with-turbo %}), [URL routing]({% post_url turbo-ios/2021-02-26-url-routing %}), [forms, and basic authentication]({% post_url turbo-ios/2021-03-19-forms-and-basic-authentication %}). This week, we will customize our app to make it feel more native.

{% include series.liquid %}

One of the big trade-offs of hybrid apps is that all interaction (and content) usually lives in the web view. This means we can update it without much issue by making changes to our Rails app. But what if we want a native navigation bar button? Or want to register a notification token with the server?

Enter the JavaScript bridge, the intersection of client and server. With this bridge, we can pass messages between the two worlds without waiting for someone to tap a link.

Like most bridges, this one is a two-way street. Let’s first dive into how the client can post messages to the rendered HTML. Then we will cross back over by talking to the client.

## Client → Server

`WKWebView`, the web view that Turbo is built on top of, has a helper to evaluate arbitrary JavaScript. The method expects the JavaScript to execute and a completion handler. You can handle the returned object or raised error with the completion block.

```swift
let webView = session.webView
let script = "document.body.style.background = 'orange';"
webView.evaluateJavaScript(script) { object, error in
    if let error = error {
        // handle error
    } else if let object = object {
        // success
    }
}
```

> If you are targeting iOS 14+ I recommend taking a look at [`callAsyncJavaScript( _:arguments: in: in: completionHandler:)`](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript), which automatically serializes arguments.

Now that we know how to execute a script, let’s integrate with our server’s JavaScript. First, create a new JavaScript file in your `app/javascript/` directory. I put mine under a new folder named "turbo."

```javascript
// app/javascript/turbo/bridge.js
export default class Bridge {
  static sayHello() {
    document.body.innerHTML = "<h1>Hello!</h1>"
  }
}
```

Then, attach this new class to the `window` by adding the following to your `application.js` pack file. This enables us to call into `Bridge` from any context, like our mobile app.

```javascript
import Bridge from "turbo/bridge.js";
window.bridge = Bridge;
```

Finally, call your bespoke JavaScript from the mobile app. This method can’t fail and doesn’t return anything, so we are ignoring the two parameters of the callback.

```swift
let webView = session.webView
let script = "window.bridge.sayHello();"
webView.evaluateJavaScript(script) { _, _ in }
```

### POSTing push notification tokens

We can extend this technique to do something _actually_ useful, like associating a notification token with the sign in user.

First, let’s get the Rails code out of the way. Feel free to skip this code snippet if you already have an endpoint to register notification tokens. We need...

1. A place to store the tokens 
2. An association with the user
3. A controller to create the new token
4. Routing to accept the POST request

```ruby
# 1. db/migrate/create_notification_tokens.rb
class CreateNotificationTokens < ActiveRecord::Migration
  def change
    create_table :notification_tokens do |t|
      t.belongs_to :user
      t.string :token, null: false

      t.timestamps
    end
  end
end

# 2. app/models/user.rb
class User < ApplicationRecord
  has_many :notification_tokens
end

# 3. app/controllers/notification_tokens_controller.rb
class NotificationTokensController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def create
    current_user.notification_tokens.find_or_create_by!(token: params[:token])
    head :ok
  end
end

# 4. config/routes.rb
Rails.application.routes.draw do
  resources :notification_tokens, only: :create
end
```

Next up is the JavaScript.  Add a new method to your `Bridge` class that accepts the token as a parameter and POSTs the token as JSON.

```javascript
export default class Bridge {
  static register(token) {
    fetch("/notification_tokens", {
      body: JSON.stringify({ token: token }),
      method: "POST",
      headers: { "Content-Type": "application/json" },
    });
  }
}
```

Finally, we can call this function from our native code like before.

```swift
let webView = session.webView
let script = "window.bridge.register(\(token));"
webView.evaluateJavaScript(script) { _, _ in }
```

Since we are already authenticated in the web view we don’t need to pass any sort of authentication with the request. This saves us a _ton_ of Swift networking boilerplate. The downside is we need to ignore the CSRF check in the controller, but this can be avoided by [adding the token to the POST request](https://discuss.hotwired.dev/t/csrf-token-invalidauthenticitytoken/91/3).

## Server → Client

OK, so now we have the iOS app talking to our Rails app. But what about the other way around? How do we send a message from Rails to the iOS client?

In a similar fashion to above, we need to expose a JavaScript hook. WebKit provides a convenient interface to receive JavaScript messages in a single delegate callback.

Let’s get started by creating our message handler. This class needs to conform to the `WKScriptMessageHandler` protocol and implement a single method. 

```swift
class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        print("JavaScript message received", message.body)
    }
}
```

We can then attach this to our web view via the configuration and pass it along to Turbo’s `Session`. The `name` parameter provides a namespace, here we are using `nativeApp`.

```swift
let configuration = WKWebViewConfiguration()
let scriptMessageHandler = ScriptMessageHandler()
configuration.userContentController.add(scriptMessageHandler, name: "nativeApp")

let session = Session(webViewConfiguration: configuration)
// ...
```

Now, our Rails app can post JavaScript messages via WebKit’s message handlers via the namespace set above. This message will arrive in our delegate callback with a serialized `body` of type `[String: Any]`. 

```javascript
window.webkit.messageHandlers.nativeApp
  .postMessage({name: "Message Name", more: "data"});
```

From there, we can parse out the name and any additional parameters. And based on which message we receive we can perform different native functionality.

### Dynamically adding a native button

One of my clients uses this approach to add a native `UIBarButtonItem` to some screens. We call it an _Action Button_ and configure everything from the server, including:

1. Which screens show the button
2. The icon the button displays
3. Which URL to load when tapping the button

![A native UIBarButton item](/assets/images/turbo-ios/the-javascript-bridge/my-customers.png){:standalone .unstyled.max-w-xs}

For screens that should show the button we post the following JavaScript message.

```javascript
window.webkit.messageHandlers.nativeApp.postMessage({
  name: "ActionButton",
  path: "/customers/new",
  icon: "plus"
});
```

We attach a delegate to our script message handler and pass along the action. This bridges the gap between JavaScript and Swift.

```swift
protocol ScriptMessageDelegate: class {
    func addActionButton(url: URL, imageName: String)
}

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var delegate: ScriptMessageDelegate?

    init(delegate: ScriptMessageDelegate) {
        self.delegate = delegate
    }

    func userContentController(
        _ userContentController: WKUserContentController, 
        didReceive message: WKScriptMessage
    ) {
        guard
            let body = message.body as? [String: Any],
            let path = body["path"] as? String,
            let imageName = body["icon"] as? String
        else { return }

        let url = Endpoints.rootURL.appendingPathComponent(path)
        delegate?.addActionButton(url: url, imageName: imageName)
    }
}
```

This approach works fine for a single message. But when you have more than one I recommend creating a concrete type and doing the parsing there. A great example is [`ScriptMessage.swift`](https://github.com/hotwired/turbo-ios/blob/main/Source/WebView/ScriptMessage.swift) from the Turbo source code.

Now the fun part: Adding the button to the screen. Head back to our custom delegate callback — the one responsible for creating the handler and session. Add the button and route the URL when tapped. And my favorite, use the image name to render a [SF Symbol icon](https://developer.apple.com/sf-symbols/)!

```swift
private var nextActionButtonURL: URL?

func addActionButton(url: URL, imageName: String) {
    let image = UIImage(systemName: imageName) // 🤩
    let actionButton = UIBarButtonItem(
        image: image,
        style: .plain,
        target: self,
        action: #selector(visitActionButtonURL)
    )
    navigationController.visibleViewController?
        .navigationItem.rightBarButtonItem = actionButton
}

@objc private func visitActionButtonURL() {
    if let url = nextActionButtonURL {
        route(url: url)
    }
    nextActionButtonURL = nil
}
```

A single line of JavaScript can now add custom buttons across our entire app with different icons and different functionality. Who would ever have thought JavaScript could be so powerful for iOS developers?

## Looking ahead at Strada

Not a fan of all this JavaScript? You might be in luck. The bottom of [Hotwire’s homepage](https://hotwired.dev) hints at a new part of the puzzle, Strada.

> [Strada] standardizes the way that web and native parts of a mobile hybrid application talk to each other via HTML bridge attributes. This makes it easy to progressively level up web interactions with native replacements.

My guess is that Strada will move this "on load" JavaScript to special `<meta>` tags in the HTML’s `<head>`. And the framework will automatically parse them and provide native callbacks. This could speed up development drastically and remove the need to write custom Stimulus controllers to fire the methods.

Or maybe it’s something else entirely! Basecamp likes to keep everything quite secret until they launch, so only time will tell.

## Up next: native authentication

The [next part in this series]({% post_url 2021-05-14-turbo-ios %}) is a big one: native authentication. I’m going to dive into how to present native screens from Turbo and how to implement authentication natively – no web view required!

What are you hoping to learn about Turbo next? Let me know by [reaching out on Twitter](https://twitter.com/joemasilotti).
