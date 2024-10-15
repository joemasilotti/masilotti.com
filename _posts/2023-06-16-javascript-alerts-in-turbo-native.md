---
title: JavaScript alerts in Turbo Native
date: 2023-06-16
description: Learn how to handle data-turbo-confirm in your iOS app so you can render native Swift alerts directly from your Rails code.
---

<div class="note">
  <span class="font-semibold">Update October 15, 2024</span>: JavaScript alerts are now handled automatically in Hotwire Native: <a href="https://native.hotwired.dev" target="_blank">native.hotwired.dev</a>
</div>

Last week my client ran into an issue with their Turbo Native app. They couldn't figure out why their Turbo confirmation dialog worked on mobile web but not in the app.

Their code looked something like this:

```erb
<%= button_to "Delete event", @event, data: {
  turbo_method: :delete,
  turbo_confirm: "Delete this event?"
} %>
```

On mobile web this worked as expected, showing a native JavaScript confirmation dialog asking if the event should be deleted. But *nothing* happened in the Turbo Native app.

This is because Turbo Native doesn’t deal with `WKUIDelegate` by default. This delegate, assigned to the web view, asks the developer what to do when JavaScript alerts are presented.

Here’s how to get it working in your app. I’ll assume you have a baseline Turbo Native app working, like what we create in my [Turbo Native in 15 minutes video](https://www.youtube.com/watch?v=83wOvrNtZX4).

<p class="note">Learn better from video? <a href="https://www.youtube.com/watch?v=ELJuTPZ4_uU">Follow along on YouTube</a>.</p>

## Turbo Session with a custom web view

First, we need to go one level deeper when creating our Turbo `Session` to work with a web view directly.

We can reuse our existing configuration and create the web view instance ourselves, instead of letting Turbo handle it. Replace your `session` variable in `SceneDelegate` with the following.

```swift
private lazy var session: Session = {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent = "Turbo Native iOS"

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.uiDelegate = self // Will raise an error right now.

    let session = Session(webView: webView)
    session.delegate = self
    return session
}()
```

Note that you will see a compiler error when assigning `uiDelegate` to the web view. That’s because `SceneDelegate` doesn’t conform to the `WKUIDelegate` protocol. Let’s fix that.

```swift
extension SceneDelegate: WKUIDelegate {}
```

## Web view UI delegate methods

Now that we are building again, let’s implement the method that gets called when a confirmation dialog is presented.

```swift
extension SceneDelegate: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(false)
    }
}
```

We *always* need to call the completion handler or our app will crash. Passing `false` tells iOS, and then the JavaScript, that the user dismissed or cancelled the dialog. Send `true` to indicate that the user acknowledged or accepted the alert.

To actually display an alert to the user we can use `UIAlertController`, styled as an alert.

```swift
extension SceneDelegate: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        navigationController.present(alert, animated: true)
        completionHandler(false)
    }
}
```

Here we pass in the `message` parameter, “Delete this event?” from my client's code above, to display in the native alert.

Finally, add two buttons via `UIAlertAction` to let the user confirm or cancel the alert. Notice how we are sending a different value to the completion handler depending on the tapped button.

```swift
func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
        completionHandler(true)
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
        completionHandler(false)
    })
    navigationController.present(alert, animated: true)
}
```

And there we have it! A native dialog powered by our existing Rails + Turbo code.

![Native JavaScript alert](/assets/images/javascript-alerts-in-turbo-native/native-javascript-alert.png){:standalone}
