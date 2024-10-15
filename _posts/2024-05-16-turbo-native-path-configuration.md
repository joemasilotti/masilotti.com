---
title: The power of Turbo Native path configuration
date: 2024-05-16
description: "Level up your Turbo Native apps by moving behavior to the server with remote path configuration."
---

{% include warning.liquid %}

Turbo Native helps Rails developers build iOS and Android apps quickly, bridging the gap between web and mobile development. It unlocks big apps for small teams, requiring relatively little maintenance compared to fully native ones.

Getting started with Turbo Native is quick: all you need is your existing Rails app, a copy of Xcode or Android Studio, and my [quick-start guide]({% post_url 2024-03-28-turbo-native-apps-in-15-minutes %}). You can go from zero to working apps in less than 15 minutes.

Once you have the basics down I recommend exploring *path configuration*. This innocent looking JSON file can transform how you build Turbo Native apps. Here’s how it helps level up your Turbo Native apps by moving configuration out of native code and onto your server.

## Hard-coded behavior

Let’s start with an example I see while working with almost every one of [my consulting clients]({% link _pages/services.liquid %}): presenting forms as modals.

> Modality is a design technique that presents content in a separate, dedicated mode that prevents interaction with the parent view and requires an explicit action to dismiss. - [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/modality)

![Examples of modals on iOS and Android](/assets/images/turbo-native-path-configuration/modal-examples.png){:standalone .unstyled}

A first pass at implementing this behavior might look something like this on iOS, presenting all routes that end in `/new` modally:

```swift
if proposal.url.pathComponents.last == "new" {
    navigationController.present(controller, animated: true)
} else {
    navigationController.push(controller, animated: true)
}
```

But then you realize you also need to handle the “edit” pages, too:

```swift
if proposal.url.pathComponents.last == "new" ||
    proposal.url.pathComponents.last == "edit"
{
    navigationController.present(controller, animated: true)
} else {
    navigationController.push(controller, animated: true)
}
```

And that works great! Every time the user visits a form-like URL, one ending in `/new` or `/edit`, the screen will be presented as a modal. You deploy to the app stores and go on your way.

A few weeks later you add a new screen to your Rails app, a user profile page. Users visit this screen to change their name, timezone, and other settings. To keep things clean you name the route `/profile`.

But to present this new route as a modal you’ll need to update the native codebase. Not the cleanest code but it works.

```swift
if proposal.url.pathComponents.last == "new" ||
    proposal.url.pathComponents.last == "edit" ||
    proposal.url.path() == "profile" {
{
    navigationController.present(controller, animated: true)
} else {
    navigationController.push(controller, animated: true)
}
```

The problem is that this native change requires submitting a new version to the app stores. And even after this version is released, if folks don’t update their app they’ll never see the profile screen as a modal. Ugh.

There’s got to be a better way!

## Path configuration to the rescue

Path configuration is a JSON file comprised of `rules` and `settings`:

- `rules` map URL paths to behavior, determining how different screens appear in the app.
- `settings` is an arbitrary hash, completely custom to your app and logic. For example, I use them to configure a native tab bar.

Each entry in the `rules` array is referred to as a “rule”, consisting of:

- `patterns` is an array of URL paths to match via regex.
- `properties` is a hash of configuration to apply to the matched URL path.

Converting the example from above, “presenting forms as modals”, looks like this:

```json
{
  "settings": {},
  "rules": [
    {
      "patterns": ["/new$", "/edit$"],
      "properties": {
        "context": "modal"
      }
    }
  ]
}
```

Every time a user visits a URL *ending* in `/new` or `/edit` the app will know to present the screen as a modal. And the best part? Adding the new `/profile` route is as quick as adding an entry to the array!

...but how did Turbo Native *know* how to translate `context` into a modal? There are a few built-in properties that Turbo Native iOS and Android handle out of the box. Check out the [Turbo Navigator documentation](https://github.com/hotwired/turbo-ios/blob/turbo-navigator/Docs/TurboNavigator.md) for a full breakdown of all the possible combinations.

### Setting up path configuration in the apps

To actually *use* path configuration you need to tell Turbo Native where the JSON file lives. If you followed [Turbo Native in 15 minutes]({% post_url 2024-03-28-turbo-native-apps-in-15-minutes %}) then your Android app is ready to go.

iOS needs an additional line of setup. Add path configuration to your iOS app by passing in an instance of `PathConfiguration` to your Turbo Navigator, as shown below. Or follow along with my [step-by-step tutorial]({% post_url 2024-04-18-turbo-native-pull-to-refresh %}#path-configuration-on-ios).

```swift
private lazy var navigator = TurboNavigator(pathConfiguration: pathConfiguration)
private let pathConfiguration = PathConfiguration(sources: [
    .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!)
])
```

Using *local* path configuration like this bundles the JSON file with the downloaded apps. And it has a downside: changes require new releases to the app stores. Remedy this by moving to *remote* path configuration.

{% include newsletter/cta.liquid title="Want more Turbo Native? <span class='block sm:inline'>Subscribe to my newsletter!</span>" %}

## Remotely configure your apps

*Remote* path configuration moves the JSON file to the server, enabling changes in between releases to the app stores. Using Rails you can migrate pretty quickly.

First, copy the JSON file to your server by creating a new route and controller:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # ...

  resource :configuration, only: :show
end
```

```ruby
# app/controllers/configurations_controller.rb

class ConfigurationsController < ApplicationController
  def show
    render json: {
      settings: {},
      rules: [
        patterns: ["/new$", "/edit$", "^profile$"],
        properties: {
          context: "modal"
        }
      ]
    }
  end
end
```

Then tell the iOS app where the remote configuration lives by appending a `.server` option:

```swift
private let navigator = TurboNavigator()
private let pathConfiguration = PathConfiguration(sources: [
    .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
    .server(baseURL.appending(path: "configuration")) // <--
])
```

Finaly, do the same on Android with the `remoteFileUrl` option:

```kotlin
override val pathConfigurationLocation: TurboPathConfiguration.Location
    get() = TurboPathConfiguration.Location(
        assetFilePath = "json/configuration.json",
        remoteFileUrl = "$baseUrl/configuration.json" // <--
    )
```

On every app launch Turbo Native will fetch, parse, and cache remote path configuration. Not bad for one line of code per platform!

If you go with remote path configuration, here are some tips to ensure healthy and maintainable mobile apps:

- **Always include local path configuration.** Turbo Native will fall back to the local version if downloading remote path configuration fails.
- **Version your path configuration.** This allows forward and backward compatibility with new versions of your apps.
- **Use different configurations per platform.** Having a way to update iOS without affecting Android, or visas versa, ensures that you can keep a clean line of separation between the apps.

## What’s next?

Without path configuration, you're forced to hard code a bunch of URL routes into your app. This approach is brittle and requires releases to the app stores to make changes. Path configuration simplifies the mapping of behavior in Turbo Native apps, allowing you to define how different screens in your app should behave, all from a single JSON file.

And remember, modals are the tip of the iceberg. Next week I’m sharing a bunch of practical examples of how the path configuration can further advance your Turbo Native apps. Subscribe to [my newsletter]({% link _pages/newsletter.liquid %}) to get it in your inbox.

Until then, how are you using path configuration in your Turbo Native apps?
