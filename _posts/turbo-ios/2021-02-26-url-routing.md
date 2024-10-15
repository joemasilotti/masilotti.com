---
title: "Hybrid iOS apps with Turbo – Part 2: URL routing"
date: 2021-02-26
description: Part 2 covers visit actions, path configuration, error handling, native view controllers, and more with Turbo iOS.
series: turbo-ios
series_title: URL routing
---

{% include warning.liquid %}

This is part 2 of a [6-part series on Hybrid iOS apps with Turbo]({% post_url 2021-05-14-turbo-ios %}). In [part 1]({% post_url turbo-ios/2021-02-18-hybrid-apps-with-turbo %}) we touched on the basics of the Turbo framework and why hybrid can be a great choice. We went through the [official Quick Start guide](https://github.com/hotwired/turbo-ios/blob/main/Docs/QuickStartGuide.md) line by line and ended up with a working Turbo Native demo.

{% include series.liquid %}

But a few links were broken and we shoved a bunch of code in the `SceneDelegate`. This week focuses on the different types of routing available in Turbo and how we implement each flavor. It also covers a couple of gotchas that are easy to miss but hard to fix.

Let’s dive in!

<p class="note">All the code for this series can be found on my GitHub repository, <a href="https://github.com/joemasilotti/Turbo-iOS-Demo">Turbo-iOS Demo</a>. Each article has a "start" and "complete" branch if you'd like to follow along.</p>

## URL routing with Turbo

Here are the different types of routing we will cover from the Turbo framework in this piece. Each lines up nicely with a broken link (or two) in the demo.

1. Visit actions
2. Path configuration
3. Error handling
4. External links
5. Introduction to forms (and authentication)

## But first, a quick refactor

Last week’s code example threw all of the Turbo-related code right in the `SceneDelegate`. Let’s move that to a new object so we can easily extend the behavior in the future.

### Introducing the `AppCoordinator`

To start, we can move all of our logic to a coordinator. We won’t be diving too deep into the coordinator pattern in this post. For now, think of this as a helper object that orchestrates the "flow" of the app. It will be in charge of bridging the gap between Turbo and the UI.

Pull down my [Turbo-iOS Demo](https://github.com/joemasilotti/Turbo-iOS-Demo) codebase and checkout the `part-2/start` branch. Notice that we moved all of the Turbo-related logic to `AppCoordinator`. Now `SceneDelegate` is left to do one thing: manage the scene.

Next, let’s dig into our first broken link.

## 1. Visit actions

We find our first broken link by tapping "Navigate to another page" then "Replace with another webpage." This navigation should not have _pushed_ a new view controller onto the stack. Instead, it should have _replaced_ the visible content.

![This should have been a modal.](/assets/images/turbo-ios/url-routing/push-or-replace.png){:standalone .unstyled.max-w-xs}

This introduces a new Turbo concept: visit actions. Each time a link is clicked Turbo exposes the type of action in the `session(_:didProposeVisit:)` delegate callback.

The second parameter is a `VisitProposal`. This encapsulates all the information about the link being clicked. Most of the logic in the app will derive from interpreting the contents of this object.

Note the object hierarchy below. We can determine which action was triggered via: `proposal.options.action`.

```swift
public struct VisitProposal {
    public let url: URL
    public let options: VisitOptions
    public let properties: PathProperties
}

public struct VisitOptions: Codable, JSONCodable {
    public let action: VisitAction
    public let response: VisitResponse?
}

public enum VisitAction: String, Codable {
    case advance
    case replace
    case restore
}
```

### `advance` visit action

Advance is the most commonly used action and also the most straightforward. When a link is clicked via the `advance` action a new screen should be _pushed_ onto the navigation stack.

### `replace` visit action

Instead of pushing a view controller onto the stack, `replace` instead...well... replaces it. This gives the impression of the content reloading or updating to reflect a change.

A major benefit is that we can submit a form then replace the form contents with the "show" CRUD action to give the impression of modifying content natively.

### `restore` visit action

We won’t generate `restore` links directly but will need to handle them in the app. These are reserved for revisiting content that should already be cached - for example, navigating back to a previous page.

Moving forward, we will handle `restore` actions the same way as `replace` ones.

### Handle non-advance Turbo links in the app

Now that we understand how visit actions work, lets implement the changes in our iOS app. We will start at the delegate callback mentioned earlier.

Change the implementation to pass the visit action along with the URL. 

```swift
func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
    visit(url: proposal.url, action: proposal.options.action)
}
```

Next, update  `visit(url:)` to accept the new parameter. When we get a non-advance visit, we want to replace the last controller with our new one. As a convenience, we can also default the `action:` parameter to `advance`.

```swift
private func visit(url: URL, action: VisitAction = .advance) {
    let viewController = VisitableViewController(url: url)
    if action == .advance {
        navigationController.pushViewController(viewController, animated: true)
    } else {
        navigationController.viewControllers = Array(navigationController.viewControllers.dropLast()) + [viewController]
    }
    session.visit(viewController)
}
```

By setting the navigation controller’s `viewControllers` property directly, we don’t trigger any animations. It all happens at the same time we get a seamless transition into replacing the screen.

## 2. Path configuration

Tap on that "Load a page modally" link. See how it slides up from the bottom of the screen like a native modal? Oh, what? It doesn’t? Ah, silly me. We haven’t added routing yet!

Routing, in the context of Turbo, is the translation of links to view controllers and presentation styles. It enables you to render native view controllers, present screens modally, and do all sorts of custom logic.

At its core, routing is based on the URL, allowing specific "type" of URLs to behave differently. For example, you could present all URLs ending in `/new` to be presented modally. Or, you could show a native view controller when the path is `/settings`.

### `PathConfiguration.json`

Lucky for us, Turbo has taken the hard work out of URL routing. Instead of manually parsing regexes or other custom logic, we can provide a single JSON file to the framework.

This path configuration file maps URLs to behavior via regexes. When a URL is mapped we can pry into the associated rules that were applied via `PathProperties`, accessed via `Proposal.properties`.

Here’s a snippet from the [example path configuration file](https://github.com/hotwired/turbo-ios/blob/main/Docs/PathConfiguration.md) from the Turbo-iOS repository. Let’s walk through this and cover what each line means.

```json
{
  "settings": {
    "enable-feature-x": true
  },
  "rules": [
    {
      "patterns": [
        "/new$",
        "/edit$"
      ],
      "properties": {
        "presentation": "modal"
      }
    }
  ]
}
```

First we have the `settings` section. These are properties that are applied to each and every URL when routed. They are useful for feature flags and toggling other generic behavior.

Next is the `rules` section, the meat of the file. Only one rule is listed but it matches two different patterns. If the routed URL ends in `/new` or `/edit` we want to present this screen modally.

### Wire up the path configuration

The first step is adding the JSON file to the project and letting `Session` know about it. Under the `Resources` group add a new file named `PathConfiguration.json` with the following content.

```json
{
  "rules": [
    {
      "patterns": [
        "/new$"
      ],
      "properties": {
        "presentation": "modal"
      }
    }
  ]
}
```

Then, update the `session` lazy variable to be configured with our local JSOn file.

```swift
private lazy var session: Session = {
    let session = Session()
    session.delegate = self
    session.pathConfiguration = PathConfiguration(sources: [
        .file(Bundle.main.url(forResource: "PathConfiguration", withExtension: "json")!),
    ])
    return session
}()
```

#### Remote configuration

If you typed this out manually you might notice that `PathConfiguration` takes a few different types of sources. We are only using the local one, but you can also point it directly to a URL on your server.

The local file is loaded first, then the configuration is overridden with the remote one, if given. This enables remote configuration of URLs and routes without updating your app!

### Route the URL

Now that we’ve assigned our rules, how do we actually apply the routing? Let’s revisit our `SessionDelegate` callback and expose the properties to `visit(url:action:)`.

```swift
func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
    visit(url: proposal.url, action: proposal.options.action, properties: proposal.properties)
}
```

Now we need to update our `visit` signature to handle the new parameter. Like last time, give it a sane default for when we don’t know or care about the properties.

Also, before pushing or replacing our view controller let’s check for the presentation property. If its equal to `modal`, then we present the view controller instead of pushing it on the navigation stack.

```swift
private func visit(url: URL, action: VisitAction = .advance, properties: PathProperties = [:]) {
    let viewController = VisitableViewController(url: url)
    if properties["presentation"] as? String == "modal" {
        navigationController.present(viewController, animated: true)
    } else if action == .advance {
        navigationController.pushViewController(viewController, animated: true)
    }
    /* ...*
}
```

Now the modal link should work as expected. Do note that we haven’t handled the "Submit Form" link yet, and tapping it will cause odd things to happen. Rest assured, we will get to forms later in the series.

![Presented as a modal](/assets/images/turbo-ios/url-routing/modal.png){:standalone .unstyled.max-w-xs}

### Dismissing the modal breaks the app!

Uh-oh, looks like we introduced a bug. If you dismiss the modal, you can no longer tap on any links.

This is caused by the way Turbo works under the hood. There’s a lot of [magic](https://github.com/hotwired/turbo-ios/blob/ca008e8215c66c2a276862375709b5c819b8b8b8/Source/Visitable/Visitable.swift#L43) going on to make sure each link visit transition occurs smoothly, all out of the scope of this series.

For now, all we need to know is that modals need their own `Session`. This ensures that a) dismissing a modal doesn’t break anything and b) we don’t create a new session every time someone taps this link.

First, extract the lazy variable to a helper method. Then, create a `modalSession` variable via the new helper.

```swift
private lazy var session = makeSession()
private lazy var modalSession = makeSession()

private func makeSession() -> Session {
    let session = Session()
    /* ... */
    return session
}
```

Now we only need to `visit()` the correct `session`. Replace the last line of `visit(url:action:properties:)` with the following.

```swift
if properties["presentation"] as? String == "modal" {
    modalSession.visit(viewController)
} else {
    session.visit(viewController)
}
```

## Native view controllers
This approach is not limited to presentation logic; we can also route to different view controllers. Let’s piggy-back on the example server’s "Intercept with a native view" link to show some native content.

First, add a new rule to `PathConfiguration.json`.

```json
{
  "patterns": [
    "/numbers"
  ],
  "properties": {
    "controller": "numbers"
  }
}
```

Next, rework our  `visit(url:action:properties)` implementation to dynamically create the controller based on the path properties. Also, make sure to only visit the session if the controller is `Visitable`.

```swift
private func visit(url: URL, action: VisitAction = .advance, properties: PathProperties = [:]) {
    let viewController: UIViewController

    if properties["controller"] as? String == "numbers" {
        viewController = NumbersViewController()
    } else {
        viewController = VisitableViewController(url: url)
    }

    /* ... */

    if let visitable = viewController as? Visitable {
        if properties["presentation"] as? String == "modal" {
            modalSession.visit(visitable)
        } else {
            session.visit(visitable)
        }
    }
}
```

The implementation of `NumbersViewController` isn’t relevant - it could be any native content. For completeness, here’s my implementation.

```swift
class NumbersViewController: UIHostingController<NumbersView> {
    init() {
        super.init(rootView: NumbersView())
    }
}

struct NumbersView: View {
    private let numbers = 1 ... 10

    var body: some View {
        List(numbers, id: \.self) { number in
            Text(String(number))
        }
    }
}

struct NumbersView_Preview: PreviewProvider {
    static var previews: some View {
        NumbersView()
    }
}
```

![A native view controller with Turbo iOS](/assets/images/turbo-ios/url-routing/numbers-view-controller.png){:standalone .unstyled.max-w-xs}

#### Refactor imminent…

This method is getting a little ugly, and we are checking the presence of a magic string twice. I’m going to clean this up a bit and extract a helper to check for modal presentation. See you on the [other side](https://github.com/joemasilotti/Turbo-iOS-Demo/commit/6f462dd14c220e6e4b4456aa21dcd14dfb67e569)!

## Error handling with Turbo

The next broken link is "Hit an HTTP 404 error." Clicking that shows a spinner, then a blank page. (Or, maybe this is the perfect example of a 404! 😆)

To fix this we need to address the other `SessionDelegate` callback, `session(_:didFailRequestForVisitable:error:)`. Currently, we are doing nothing more than logging the error.

Instead, let’s render the error message in a custom view. This example uses SwiftUI, but feel free to drop in any ol’ `UIViewController`.

First, create the SwiftUI view. It will be passed the error message as a string. I added this to a new group called "Views."

```swift
import SwiftUI

struct ErrorView: View {
    let errorMessage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .frame(height: 40)
            Text("Error loading page")
                .font(.title)
            Text(errorMessage)
        }
    }
}
```

Back in `AppCoordinator`, replace the implementation of the error handling with the following. This creates the `ErrorView`, wraps it in a `UIHostingController`, then positions it as a child view controller of the top view controller.

```swift
func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
    guard let topViewController = navigationController.topViewController else { return }

    let swiftUIView = ErrorView(errorMessage: error.localizedDescription)
    let hostingController = UIHostingController(rootView: swiftUIView)

    topViewController.addChild(hostingController)
    hostingController.view.frame = topViewController.view.frame
    topViewController.view.addSubview(hostingController.view)
    hostingController.didMove(toParent: topViewController)
}
```

You could also add a button to this view that tries to reload the page. Since we have a reference to the `Session` all we need to do is ask it to refresh via `session.reload()`. This will clear the Turbo cache and revisit the current page.

## External links
Up next is "Follow an external link." Tapping this opens the framework’s GitHub repository in Safari. While not technically broken, we can improve this UX by instead by opening an in-app browser.

An external link is any URL that doesn’t match Turbo’s root URL domain. We kicked off the app pointing to `https://turbo-native-demo.glitch.me`, so anything that doesn’t match `turbo-native-demo.glitch.me` is considered "external" by the framework.

### `WKNavigationDelegate`

The callback for these links happens in a new delegate, `WKNavigationDelegate`. This lives off of the web view provided by Turbo’s `Session`.

Add the following to `SessionDelegate`. This makes the coordinator the navigation delegate only when a Turbo request finishes.

```swift
func sessionDidLoadWebView(_ session: Session) {
    session.webView.navigationDelegate = self
}
```

Then, extend `AppCoordinator` to implement the new delegate. This also requires importing `WebKit` and making the coordinator inherit from `NSObject`.

```swift
import WebKit

class AppCoordinator: NSObject {
    /* ... */
}

extension AppCoordinator: WKNavigationDelegate {}
```

### `SFSafariViewController`

All that’s left is actually displaying the content. I’m using the [standard in-app browser](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) but you are free to roll your own.

Implement `webView(_: decidePolicyFor:decisionHandler:)` in the navigation delegate. We only want to catch tapped links, so we want to check that the navigation type is `.linkActivated`. If so, we cancel the request and handle it on our own, via the Safari view controller.

```swift
import SafariServices

func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard
        navigationAction.navigationType == .linkActivated,
        let url = navigationAction.request.url
    else {
        decisionHandler(.allow)
        return
    }

    let safariViewController = SFSafariViewController(url: url)
    navigationController.present(safariViewController, animated: true)
    decisionHandler(.cancel)
}
```

## Introduction to forms (and authentication)

A big surprise with Turbo development is that all non-GET requests are ignored. This means that normal (non-remote) form submissions no-op. No error message, no logs, just… nothing.

The short answer is that you need to convert these forms to AJAX. In a Rails world, this means `remote: true` or `local: false`, depending on which version of Rails you are running.

If you are on Rails 6.1 and Turbo v7, however, you can ignore all of this. All form submissions are handled via JavaScript which makes Turbo Native "just work" by default. If you are still running Turbolinks (Turbo v5) then you need to convert all of your forms by hand.

Part 3 will address the form conversion with a generic Stimulus controller. A client is using this JavaScript in production for 30+ forms while we transition from Turbolinks to Turbo.

We will also transition from the Turbo demo server to a real Rails app. Then, finally, can we start to talk about authentication!

Have you given hybrid a fair shot? What’s holding you back from porting your Ruby on Rails app to iOS? I’d love to know! Feel free to  [send me an email](mailto:joe@masilotti.com)  or  [reach out on Twitter](https://twitter.com/joemasilotti).
