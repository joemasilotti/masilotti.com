---
title: "Hybrid iOS apps with Turbo – Part 6: Tips and tricks"
date: 2021-05-13
description: Tips and tricks I’ve picked up over the years that help make the app feel more native and development easier.
series: turbo-ios
series_title: Tips and tricks
---

{% include warning.liquid %}

At this point in the [Hybrid iOS series]({% post_url 2021-05-14-turbo-ios %}), you should have a working Turbo Native app. To wrap up the series I’m sharing tips and tricks I’ve picked up over the years that range from making development easier to making the app feel more native.

If you’re still new to Turbo iOS, check out the beginning of the series, [The Turbo framework]({% post_url turbo-ios/2021-02-18-hybrid-apps-with-turbo %}) . I walk you through building a Turbo Native app from scratch, including all the Ruby on Rails code needed for your server.

{% include series.liquid %}

## Developer quality of life improvements

To start, here are a few techniques I add to almost every Turbo Native app I work on. They make my life easier when I’m adding new code and help deal with how dynamic a Rails app can be.

### Dismiss a modal after submitting a form

If you followed along with the [URL routing part of this series]({% post_url turbo-ios/2021-02-26-url-routing %}), your app is set up to present `/new` and `/edit` paths in a modal. Tapping a link, or submitting a form, can sometimes cause weird behavior with this set up.

A quick workaround is to always dismiss a presented controller before doing any navigation. You can safely call dismiss even if there isn’t anything currently being presented.

```swift
private func visit(url: URL, action: VisitAction = .advance) {
    navigationController.dismiss(animated: true)

    // The rest of your implementation...
}
```

### Fix for “double” pushed controllers

Some apps might experience the same screen being pushed twice on the navigation stack. Another quick fix is to replace, not push, if the proposed URL is the same as the one currently being displayed.

```swift
func visit(url: URL, action: VisitAction = .advance) {
    let viewController = VisitableViewController(url: url)

    if session.activeVisitable?.visitableURL == url {
        replaceLastController(with: viewController)
    } else if action == .advance {
        navigationController.pushViewController(viewController, animated: true)
    } else {
        replaceLastController(with: viewController)
    }

    session.visit(viewController)
}

func replaceLastController(with controller: UIViewController) {
    let viewControllers = navigationController.viewControllers.dropLast()
    navigationController.setViewControllers(viewControllers + [controller], animated: false)
}
```

### Endpoints - development vs. TestFlight vs. production

There are usually 3 environments you need to worry about when building iOS apps: local development, TestFlight, and apps downloaded via the App Store (production). 

Here’s how I configure my apps to point to different servers, depending on how the app was installed on the device.

First, create an `Environment` enum with a case for each environment. Expose a static property that determines which environment we are currently running in.

```swift
enum Environment: String {
    case development, staging, production
}

extension Environment {
    static var current: Environment {
        if isTestFlight {
            return .staging
        } else if isDevelopment {
            return .development
        }
        return .production
    }

    private static var isTestFlight: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.path.contains("sandboxReceipt")
    }

    private static var isDevelopment: Bool {
        ProcessInfo.processInfo.environment["ENVIRONMENT"]?.lowercased() == "development"
    }
}
```

TestFlight builds are determined by a special receipt URL. This is used to test in-app purchases so they don’t conflict with “real” ones from the App Store.

Development builds are determined by an environment variable. You can set this on the scheme by adding `"ENVIRONMENT"` and setting the value to `"development"`.

![Setting an environment variable for the scheme](/assets/images/turbo-ios/tips-and-tricks/environment-variable.png){:standalone}

Then create another object, `Endpoint`, that returns the URL based on the current environment. Customize each option to match your needs, like development port or staging/production URLs.

```swift
enum Endpoint {
    static var root: URL {
        switch Environment.current {
        case .development:
            return URL(string: "http://localhost:3000")!
        case .staging:
            return URL(string: "https://staging.example.com")!
        case .production:
            return URL(string: "https://.example.com")!
        }
    }
}
```

Now you can reference the base URL with `Endpoint.root` and the environment is automatically taken into consideration. Use this when loading your initial page on the Turbo `Session`.

```swift
visit(url: Endpoint.root.appendingPathComponent("/home"))
```

## Make your hybrid app feel more native

For the biggest impact, convert screens one-by-one to native when needed, like your [sign in screen]({% post_url turbo-ios/2021-04-22-native-authentication %}). Map views are also great candidates because the native experience is so much better than the web. However, these are big investments – they usually require a lot of native code and new API endpoints.

Before reaching for native, try these low hanging fruits. They are only a few lines of code each but can go a long way in making your Turbo iOS app feel more native.

### Show/hide web content on the app

If using the [Turbo Rails gem](https://github.com/hotwired/turbo-rails), you get [this helper](https://github.com/hotwired/turbo-rails/blob/fec33d9bc767aec612b283620d2a74e78c1f90ae/app/controllers/turbo/native/navigation.rb#L46) for free. Make sure your user agent includes “Turbo Native” and you can use this throughout your application.

```swift
let session = Session()
session.webView.customUserAgent = "My Great App (Turbo Native)"
```

You can use this helper to hide content that should only appear on the web, like the “Back” button generated from a scaffold.  Or, create a new layout file and use that for native apps. 

```erb
<% unless turbo_native_app? %>
  <%= link_to "Back", board_games_path %>
<% end %>
```	

### Disable link previews and Force Touch

Tap and hold a link in your app. See how the little preview dialog appears? That doesn’t feel very native, does it!

![Link previews don't feel very native.](/assets/images/turbo-ios/tips-and-tricks/link-preview.png){:standalone .unstyled.max-w-xs}

We can disable these with one line of code. Disable link previews on the web view when you create your Turbo `Session`.

```swift
let session = Session()
session.webView.allowsLinkPreview = false
```

### Disable zoom

In a similar vein, you can disable web zoom when someone pinches the screen. Add the following to your layout template in the `<head>`.

`<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=0">`

Note that this is an accessibility issue. If someone was zooming in to increase font size, they’d no longer have this option. You might need to add custom font scaling to account for the accessibility gap.

## An iOS app template for Turbo Native apps

I worked with [Chris Oliver](https://twitter.com/excid3) to create [Jumpstart Pro iOS](https://jumpstartrails.com/ios?utm_source=masilotti.com), an iOS app template to supercharge your Rails application with easy native integration.

The template is the perfect place to kick start your native codebase. It contains implementation of all the content from this series, including:

* URL routing with modals, forms, and a navigation stack
* native authentication with SwiftUI screens
* native tab bar configured via a JSON file
* push notification registration and routing
* JavaScript bridge examples
* native screens and API examples

I’d love for you to check it out! If you have any questions or feature requests you can [reach out on Twitter](https://twitter.com/joemasilotti).
