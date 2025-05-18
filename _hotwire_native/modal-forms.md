---
title: "Present forms as modals in Hotwire Native"
description: "Set up a remote path configuration to dynamically render pages as modals, helping isolate tasks and align with native UX patterns."
order: 3
---

In native iOS and Android apps we can present screens as *modals*, having them slide up from the bottom instead of from the side. Modals provide focused, interruption-style experiences that are ideal for short, self-contained tasks.

We can take advantage of this UX pattern in Hotwire Native apps by presenting **web forms as modals**, improving:

1. Task isolation - Helps focus attention on the specific task.
1. Validation errors - Easier to handle errors with standard Rails patterns.
1. Consistency - iOS and Android users expect certain UX when using apps.

![Default screen presentation vs. modal presentation on iOS](/assets/images/hotwire-native/modal-forms/example.gif){:standalone .unstyled}

To present forms as modals we need to set up a [path configuration](https://native.hotwired.dev/overview/path-configuration) rule. This will match a URL when a user taps a link in the app and apply presentation behavior.

{% include book/promo.liquid %}

## Set up remote path configuration

Start by adding add a new route to `config/routes.rb`.

```ruby
# config/routes.rb
resource :configuration, only: :show
```

Then create a controller with a `#show` method that renders an empty JSON object.

```ruby
# app/controllers/configurations_controller.rb
class ConfigurationsController < ApplicationController
  def show
    render json: {
    }
  end
end
```

Inside the JSON object add the two required keys that path configuration requires: `rules` and `settings`. The *rules* array is where we map URL paths to behavior. We'll cover *settings* in a future article.

{% highlight ruby mark_lines="5 6 7" %}
# app/controllers/configurations_controller.rb
class ConfigurationsController < ApplicationController
  def show
    render json: {
      settings: {},
      rules: [
      ]
    }
  end
end
{% endhighlight %}

Rails *forms* can usually be identified by their URL path ending in `/new` or `/edit`. So we'll add a rule to match those, setting the *context* property to *modal*.

{% highlight ruby mark_lines="7 8 9 10 11 12 13 14 15" %}
# app/controllers/configurations_controller.rb
class ConfigurationsController < ApplicationController
  def show
    render json: {
      settings: {},
      rules: [
        {
          patterns: [
            "/new$",
            "/edit$"
          ],
          properties: {
            context: "modal"
          }
        }
      ]
    }
  end
end
{% endhighlight %}

> Note that the *patterns* key matches via regex, hence the trailing `$` to match the end of the string.

By hosting the configuration on the Rails server then we can **dynamically change behavior**. Add a new entry to the `patterns` array to present a new screen as a modal. The next launch will configure the app with the new configuration - all without a new release to the app stores!

We now have our remote path configuration available at `/configuration.json`. Up next is telling the Hotwire Native apps where to find it.

## Use the remote path configuration

Load the path configuration in the iOS app from `AppDelegate.swift`. This ensures the configuration is ready before the app makes it first request.

{% highlight swift mark_lines="1 7 8 9 10" %}
import HotwireNative
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let url = URL(string: "http://localhost:3000/configuration.json")!
        Hotwire.loadPathConfiguration(from: [
            .server(url)
        ])
        return true
    }
}
{% endhighlight %}

Same for Android, load the path configuration in your `Application()` subclass or in `MainActivity.kt` at the end of `onCreate(savedInstanceState:)`.

{% highlight kotlin mark_lines="8 9 10 11 12 13" %}
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.turbo.config.PathConfiguration

class MainActivity : HotwireActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // ...

        Hotwire.loadPathConfiguration(
            context = this,
            location = PathConfiguration.Location(
                remoteFileUrl = "http://localhost:3000/configuration.json"
            )
        )
    }
}
{% endhighlight %}

Forms will now be presented as modals on both platforms, helping users focus on the task and providing consistency with native UX patterns. And `context` isn't the only property available, check out [the docs](https://native.hotwired.dev/reference/path-configuration#properties) for more available options.

## Bonus tips

Here are a few ideas on how you could enhance your path configuration.

1. Remove the hardcoded `localhost` URL in the apps with dynamic resolution based on the environment. (Tutorial coming soon!)
1. [Version the path configuration](https://native.hotwired.dev/overview/path-configuration#versioning) for forward and backward compatibility with new app versions.
1. Set `Hotwire.config.showDoneButtonOnModals = true` on iOS to automatically add a Done button to screens presented as modals.
