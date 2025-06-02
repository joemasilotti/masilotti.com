---
title: "Set native screen titles in Hotwire Native"
date: 2025-05-18
og_title: "Set native screen titles in<br>Hotwire Native"
description: "Make your Hotwire Native apps feel more native with dynamic screen titles - all from your Rails codebase."
order: 1
---

One of the biggest selling points for using [Hotwire Native]({% link _pages/hotwire-native.liquid %}) is having all of your content exist in one spot: the web. This enables a large portion of your application logic to live where you're most comfortable: Ruby on Rails code.

But even when rendering mostly web content, there are still ways to make your apps feel more native. And some of them don’t require *any* Swift or Kotlin code to implement. A quick win is understanding how native screen titles are set in Hotwire Native apps.

**Both platforms automatically set native screen titles from the `<title>` HTML attribute on the page.** On iOS this sets the *navigation bar title* and on Android the *action bar title*.

For example, with the following application HTML layout:

```html
<html>
  <head>
    <title>Dashboard</title>
  </head>

  <body>
    <!-- ... -->
  </body>
</html>
```

You’ll automatically see “Dashboard” rendered at the top of the screen in iOS and Android Hotwire Native apps. All without writing a single additional line of Swift or Kotlin.

![Native screen titles on Hotwire Native iOS and Android apps](/assets/images/hotwire-native/native-screen-titles/native-screen-titles.png){:standalone .unstyled}

But this quickly falls apart if you’re not using the same `<title>` across your entire app. Instead, I like to provide a bit more context and set it dynamically based on the page content currently being rendered.

{% include book/promo.liquid %}

## Dynamic `<title>`s

I use the [`content_for`](https://apidock.com/rails/ActionView/Helpers/CaptureHelper/content_for) helper to dynamically set the `<title>` from the view.

For example, on a dashboard page I’d set the title:

```erb
<%# app/views/dashboards/show.html.erb %>

<% content_for :title, "Dashboard" %>
```

And then in the application’s HTML layout I’d render that value in `<title>`, making sure to fall back to something generic in case it wasn’t set.

```erb
<html>
  <head>
    <title><%= content_for(:title) || "Default Title" %></title>
  </head>

  <body>
    <!-- ... -->
  </body>
</html>
```

This approach gives our Hotwire Native apps more native look and feel. And the best part? Because all of the changes are made in the Ruby on Rails codebase, we don’t even need to release a new version to the app stores.
