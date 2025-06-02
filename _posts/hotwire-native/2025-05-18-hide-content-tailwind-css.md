---
title: "Hide content with Tailwind CSS in Hotwire Native"
date: 2025-05-18
og_title: "Hide content with Tailwind CSS<br>in Hotwire Native"
description: "Get rid of duplicate page titles and make your app feel more native with a Tailwind CSS custom variant."
order: 2
---

Mobile apps built with [Hotwire Native]({% link _pages/hotwire-native.liquid %}) let Rails developers reuse logic across multiple platforms. By rendering existing web content on iOS *and* Android, small teams can ship big apps in a fraction of the time. But sometimes shoving a web view inside of native app chrome can look a little... off.

Here's an example from the hiking app you build in while working through [my book on Hotwire Native]({{ site.data.urls.book }}). This screen lists hikes that you recently completed. Notice the "Hikes" up at the top *and* in the web content?

![Double titles on Hotwire Native iOS and Android apps](/assets/images/hotwire-native/hide-content-tailwind-css/double-titles.png){:standalone .unstyled}

Hotwire Native automatically [sets *native* screen titles from the `<title>` HTML attribute]({% post_url hotwire-native/2025-05-18-native-screen-titles %}) on the page. Combine that with an innocent `<h1>` tag and you've got yourself a wonky-looking screen.

We can remedy this by **hiding specific content when rendered in Hotwire Native apps**. First we'll explore how to do this with Ruby and then with Tailwind CSS.

{% include book/promo.liquid %}

## Hide Hotwire Native content with Ruby

By default, Hotwire Native apps report a user agent that contains the string "Hotwire Native". Combined with the `hotwire_native_app?` helper included in [turbo-rails](https://github.com/hotwired/turbo-rails/blob/main/app/controllers/turbo/native/navigation.rb#L8-L10), we can hide content with an `unless` statement.

```erb
<%# app/views/layouts/application.html.erb %>
<html>
  <head>
    <%# Set native screen title. %>
    <title>Hikes</title>
  </head>
</html>
```

```erb
<%# app/views/hikes/index.html.erb %>
<% unless hotwire_native_app? %>
  <h1>Hikes</h1>
<% end %>
```

Now the `<h1>` only gets rendered in the browser and not for Hotwire Native apps.

![Single title on Hotwire Native iOS and Android apps](/assets/images/hotwire-native/hide-content-tailwind-css/single-title.png){:standalone .unstyled}

If we won't want to hard code a bunch of `unless` statements in our app, we can turn to CSS.

## Hide Hotwire Native content with CSS

First, use the `hotwire_native_app?` helper to set a new `data-*` attribute in the DOM. We'll use this to let our CSS know the request was made from the apps.

```erb
<%# app/views/layouts/application.html.erb %>
<html>
  <body <%= "data-hotwire-native" if hotwire_native_app? %>>
    <%# ... %>
  </body>
</html>
```

Then, update your Tailwind CSS v4 configuration file to add a [custom variant](https://tailwindcss.com/docs/adding-custom-styles#adding-custom-variants).

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";

@custom-variant hotwire-native {
  body[data-hotwire-native] & {
    @slot;
  }
}

@custom-variant not-hotwire-native {
  body:not([data-hotwire-native]) & {
    @slot;
  }
}
```

We can now prepend `hotwire-native:` to *any* CSS class for it to apply only in the apps. Or `not-hotwire-native:` to apply everywhere *but* the apps.

Hiding the `<h1>` from earlier no longer requires Ruby code but a single CSS class.

```erb
<%# app/views/hikes/index.html.erb %>
<h1 class="hotwire-native:hidden">Hikes</h1>
```

If you're working with Tailwind CSS v3 then add the custom variants to your JavaScript configuration file instead.

```javascript
module.exports = {
  content: [],
  theme: {
    extend: {}
  },
  plugins: [
    ({ addVariant }) => {
      addVariant("hotwire-native",
        "body[data-hotwire-native] &"
      ),
      addVariant("not-hotwire-native",
        "body:not([data-hotwire-native]) &"
      )
    }
  ]
}
```

We can now customize the design of the Hotwire Native apps entirely with CSS. And every change will apply as soon as we deploy our Rails code, no app store updates required.
