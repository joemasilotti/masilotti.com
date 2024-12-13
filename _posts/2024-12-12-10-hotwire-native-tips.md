---
title: 10 tips from 10 years of Hotwire Native
date: 2024-12-12
description: "After a decade of building Hotwire Native apps, I’m sharing my top 10 tips to help you keep logic on the server and make hybrid app development even easier."
---

10 years ago I launched my first Hotwire Native app in the App Store. It was called something different back then (anyone remember Turbolinks?) but a lot of the same concepts and learnings apply.

To celebrate my 10-year anniversary, here are 10 of my favorite Hotwire Native tips and tricks. These will help make your hybrid app feel more native and achieve the number one goal of Hotwire Native: leaving as much business logic on the server as possible.

P.S. You don’t want to miss #10. 😉

## 1. Conditional content with `hotwire_native_app?`

Hide content in the apps by putting it behind a `hotwire_native_app?` helper.

```erb
<% unless hotwire_native_app? %>
  <%= render "mobile_header" %>
<% end %>
```

This comes bundled with [turbo-rails](https://github.com/hotwired/turbo-rails), which is included in new Rails apps by default. It returns `true` when the user agent includes “Hotwire Native”, which Hotwire Native automatically does for us.

## 2. Custom CSS

Remove the conditional and hide content in the apps via CSS with a native-specific stylesheet.

```css
/* native.css */
.d-hotwire-native-none {
  display: none !important;
}
```

Then only include that stylesheet for the mobile apps.

```erb
<%# app/views/layouts/application.html.erb %>
<html>
<head>
  <%= stylesheet_link_tag "application" %>
  <%= stylesheet_link_tag "native" if hotwire_native_app? %>
</head>
<%# ... %>
</html>
```

Apply the new CSS class to hide content in the apps but not on the web.

```erb
<%# app/views/shared/_mobile_header.html.erb %>
<nav class="d-hotwire-native-none">
  <%# ... %>
</nav>
```

## 3. Persistent web-based login with Devise

Keep users signed in “forever” with a long-lived cookie. In your sign-in form, programmatically “check” `remember_me`, telling Devise to remember the user. Hotwire Native will automatically persist this cookie for future app launches, ensuring the user stays signed in until they manually sign out.

```erb
<%# app/views/sessions/new.html.erb %>
<%= form_with url: session_path do |form| %>
  <% if hotwire_native_app? %>
    <%= f.hidden_field :remember_me, value: true %>
  <% else %>
    <%= f.check_box :remember_me %>
    <%= f.label :remember_me %>
  <% end %>
  <%# ... %>
<% end %>
```

## 4. Present forms as modals

Set `"context": "modal"` in your path configuration to present forms as modals in the apps. Hotwire Native handles the presentation, dismissing, and navigation to and from these forms automatically.

```json
{
  "settings": {},
  "rules": [
    {
      "patterns": [
        "/new$", "/edit$"
      ],
      "properties": {
        "context": "modal"
      }
    }
  ]
}
```

These patterns match all URL paths ending in `new` or `edit` - the default for Rails forms. Feel free to add anything custom here, too.

## 5. Replace screens

Navigate to a new screen *without* pushing a new one onto the stack with `data-turbo-action="replace"`. This is especially useful with a tab bar or accordion that swaps out content on a page.

```erb
<nav>
  <%= link_to "First tab", "#one", "data-turbo-action": "replace" %>
  <%= link_to "Second tab", "#two", "data-turbo-action": "replace" %>
</nav>
```

## 6. Manually pop screens

Dismiss a modal or navigate *backwards* in the stack using historical location URLs. Add the routes to your path configuration then use the helpers from turbo-rails.

```json
{
  "settings": {},
  "rules": [
    {
      "patterns": [
        "refresh_historical_location"
      ],
      "properties": {
        "presentation": "refresh"
      }
    }
  ]
}
```

Then navigate in a Rails controller - web apps will redirect to `posts_path` and mobile apps will pop the top screen and refresh the previous one.

```ruby
class PostsController < ApplicationController
  def create
    # ...
    refresh_or_redirect_to(posts_path) 
  end
end
```

## 7. Uncover “hidden” presentations

Buried deep in the [path configuration documentation](https://native.hotwired.dev/reference/path-configuration#properties) you’ll discover *eight* different options for `presentation`. Add these to your path configuration (like in the previous tip) to do fun things like replace the entire stack of views or remove everything from the stack. These can be useful when a user signs in or out to reset the app to a clean state.

## 8. Disable link previews on iOS

Link Previews, activated by long-pressing a link, can break the feeling of a native app. Disable them by configuring your web view to disable them.

```swift
Hotwire.config.makeCustomWebView = { config in
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.allowsLinkPreview = false
    return webView
}
```

## 9. Handle external URLs in Android

Customize the [behavior of external URLs](https://native.hotwired.dev/android/reference#handling-url-routes) (URLs that don’t match your website’s domain) by configuring decision handlers. You can use this to open the link in-app, in a browser, or something totally custom.

```kotlin
Hotwire.registerRouteDecisionHandlers(
    AppNavigationRouteDecisionHandler(),
    BrowserTabRouteDecisionHandler()
)
```

## 10. Learn more from my book - coming next month!

The beta for [Hotwire Native for Rails Developers]({% link _pages/book.liquid %}) launches in January!

This book will guide you through building web, iOS, and Android apps with confidence by keeping business logic server-side and progressively enhancing web screens to native.

After nearly two years of work and over a decade of experience with Hotwire Native, I’m excited to share it with you.

Add your email to be the first to know when the beta goes live and where to buy it:

<a href="{% link _pages/book.liquid %}" class="button button-primary button-lg">Notify me</a>
