---
title: "Enhancing Turbo Native apps: How to hide web-rendered content"
date: 2023-05-02
description: Learn two ways to conditionally show web content in your Turbo Native app. One quick and dirty and one cache-friendly.
---

{% include warning.liquid %}

Hybrid apps built with [Turbo Native](<%= url_for "_posts/2021-05-14-turbo-ios.md" %>) come with a ton of benefits. Namely, they enable small teams to ship multiplatform apps by sharing web content. They let Rails developers focus on what they do best: working in Rails.

But sometimes shoving a web view in native chrome can look a little… off. Here’s how to hide web-rendered content in a Turbo Native app to make it feel a little more native. All from the comfort of Ruby and HTML.

## Navigation bar titles and `<h1>` tags

On iOS, when we use `UINavigationController` we get a navigation bar running along the top of the screen. We can optionally set the `title` property to a string.

![Native navigation title](/assets/images/hide-web-rendered-content-on-turbo-native-apps/native-title.png){:standalone .unstyled.max-w-xs}

```swift
let viewController = UIViewController()
viewController.title = "Joe's amazing app"
UINavigationController(rootViewController: viewController)
```

Turbo Native will automatically set this from the title of the page being rendered. This means we can use `<title>Joe's amazing app</title>` from our HTML to update a native UI element. And this is built directly into turbo-ios!

But on the web we usually render a big `<h1>` near the top of a page.

![HTML <h1>](/assets/images/hide-web-rendered-content-on-turbo-native-apps/html-title.png){:standalone .unstyled.max-w-xs}

```html
<h1>Joe's amazing app</h1>
```

Combining these feels a bit weird. We have the same content, duplicated, immediately adjacent to each other.

![Double title](/assets/images/hide-web-rendered-content-on-turbo-native-apps/double-title.png){:standalone .unstyled.max-w-xs}

To make the Turbo Native app feel more native we can hide the web-based title, the `<h1>`, and rely on the native navigation bar for the title of the page.

## Custom user agent

First, we need to identify the native app. We can do so with a custom user agent.

When creating our Turbo `Session` we customize a `WKWebViewConfiguration` that sets the user agent. This gets appended to the default Safari user agent.

```swift
import Turbo
import WebKit

let configuration = WKWebViewConfiguration()
configuration.applicationNameForUserAgent = "Turbo Native iOS"

Session(webViewConfiguration: configuration)
```

Using `applicationNameForUserAgent` _appends_ the string. So we still report our actual device/browser information in requests. Line break added for readability.

```
Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X)
AppleWebKit/605.1.15 (KHTML, like Gecko) Turbo Native iOS
```

## Rails helper to identify Turbo Native apps

Back in the Rails app we can use the built in `turbo_native_app?` helper to identify the client. As long as the string "Turbo Native" is present in the user agent this method will return `true`.

This helper is provided by [turbo-rails](https://github.com/hotwired/turbo-rails/blob/main/app/controllers/turbo/native/navigation.rb#L8-L10) - along with some custom, "hidden" route helpers. More info on those in a future post!

The helper only exists in a controller context, so we need to expose it to our views.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper_method :turbo_native_app?
end
```

Then, in our views, we can determine which content to render.

```erb
<%% unless turbo_native_app? %>
  <h1>Hello, world!</h1>
<%% end %>
```

Now the `<h1>` will only be rendered on the website and not in the mobile apps.

## A cache-friendly solution

However, this conditional doesn’t work well with view caching. We are now sending different HTML over the wire for different user agents.

To remedy this we can conditionally hide content with CSS.

First, add the following to your `<body>` tag, most likely in your application layout.

```erb
<body class="<%%= "turbo-native" if turbo_native_app? %>">
```

Now a bit of custom CSS. This will hide any element with the `turbo-native:hidden` class when rendered in a Turbo Native app.

```css
body.turbo-native .turbo-native:hidden {
  display: none;
}
```

We can rework our original HTML to use the new CSS like this.

```html
<h1 class="turbo-native:hidden">Hello, world!</h1>
```

We are now always sending the same HTML, regardless of user agent. It’s up to the client to render the `<h1>` or not. And caching is happy again!

## DRYing up the title

We can take this one step farther with `content_for`. This is a [small Rails helper](https://guides.rubyonrails.org/layouts_and_rendering.html#using-the-content-for-method) that allows you to insert content into a named `yield` block in your layout.

For example, `content_for(:title, "New title")` sets the content and `content_for(:title)` renders it. Rendering the content can come "before" you set it in your code, making it quite powerful.

Here's how we can set the title of the page, and therefore the native iOS title, from our views.

```erb
# app/views/layouts/application.html.erb
<html>
  <head>
    <title><%%= content_for(:title) || "Joe's amazing app" %></title>
  </head>
</html>

# app/views/shared/_header.html.erb
<%% content_for :title, title %>
<h1 class="turbo-native:hidden"><%%= title %></h1>
```

Then, in any view in our app, we can set both the `<h1>` and `<title>` with one line of code.

```erb
<%%= render "shared/header", title: "A custom title" %>
```

This approach has the added benefit of consolidating any design or logic around the header of your app. It could be migrated to a component, too.

## Making the app feel even _more_ native

There are a bunch of other small improvements you can apply to make a Turbo Native app feel more native. Disabling link previews, native navigation buttons, in-app image viewers… the list goes on!

What would you like me to cover next? [Send me an email](mailto:joe@masilotti.com) about what you need help with.
