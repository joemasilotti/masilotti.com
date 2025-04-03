---
title: "A library of bridge components for Hotwire Native apps"
date: 2025-03-27
description: "Announcing a collection of iOS and Android bridge components to drop into your Hotwire Native apps, all extracted from real-world applications."
---

[Hotwire Native](https://native.hotwired.dev) makes it easier than ever to build hybrid mobile apps powered by your Ruby on Rails server. But when you need truly native UI elements like menus, barcode scanners, and push notifications, you’re usually stuck writing custom Swift and Kotlin code.

I’ve been solving this problem for years in [client projects]({% link _pages/services.liquid %}) and [my book]({{ site.data.urls.book }}). Now, I’m sharing my own collection of bridge components, extracted from real-world apps.

Check out my new [Bridge Components library on GitHub]({{ site.data.urls.bridge_components }}).

## What’s in the library?

![](/assets/images/bridge-components-library/promo.png){:standalone .unstyled}

* **7 free components** to get started right away.
* **5 Pro components** for advanced workflows.
* **iOS and Android support** for each component.
* **Example iOS, Android, and Rails apps** included to see them in action.
* **Full source code** - copy-paste into your app and wire up the HTML!

## How it works

To use a bridge component copy-paste the Swift/Kotlin and JavaScript files to your apps. Then wire up the HTML on any page to render the native component.

Once you copy-paste the native code into your app you modify the component's appearance and behavior **with only HTML**. That means you don't even need to resubmit to the app stores to change functionality in your apps.

This snippet uses the [Menu Component](https://github.com/joemasilotti/bridge-components/tree/main/components/menu) to add a button to the navigation bar. When tapped, it renders a native menu powered by `UIMenu` on iOS and `DropdownMenu` on Android. The title and image of each item in the menu are also customizable via `data-bridge-*` attributes.

```html
<div data-controller="bridge--menu">
  <a href="/one"
    data-bridge--menu-target="item"
    data-bridge-title="One"
    data-bridge-ios-image="1.circle"
    data-bridge-android-image="counter_1">
      One
  </a>

  <!-- More items... -->
</div>
```

![](/assets/images/bridge-components-library/MenuComponent.png){:standalone .unstyled}

## What you can build right now

These components are included in the library:

* **Alerts**: Confirm actions with a customizable native dialog.
* **Buttons**: Add native navigation bar buttons with dynamic text or icons.
* **Forms**: Present a keyboard-aware, native submit button for forms.
* **Menus**: Render native dropdown menus from the navigation bar.
* **Review Prompts**: Ask for App Store and Play Store reviews.
* **Sharing**: Trigger the native share sheet.
* **Toasts**: Display floating, disappearing messages.

### Pro components

For advanced integration with native SDKs, a Pro license includes:

* **Barcode Scanner**: Scan barcodes and QR codes using the device camera.
* **Document Scanner**: Present a camera to digitize physical documents.
* **Location Access**: Prompt the user for precise location data.
* **Push Notification Tokens**: Retrieve the device’s push notification token.
* **System Permissions**: Check status of location, notifications, and more.

Gain access to these components by [purchasing a Pro license](https://buy.stripe.com/fZeaF6bn9b9d4Pm14b). This is a **one-time payment** and not a subscription. It includes access to all bridge components available today, plus all future updates.

Use promo code <code>EARLYACCESS</code> for 25% off for a limited time.

## Get started today

Bridge Components is open-source and ready to use. Head over to the GitHub repo and start integrating native features into your Hotwire Native app.

<div class="not-prose">
  <a href="{{ site.data.urls.bridge_components }}" target="_blank" class="button button-primary button-lg flex">
    {% svg "/assets/icons/github.svg" class="h-5 w-5 mr-1.5" %}
    Bridge Components on GitHub
  </a>
</div>

I’m actively working on new components - expect more soon. [Send me an email](mailto:joe@masilotti.com) or open a GitHub Discussion and let me know what you think. Your feedback will help shape the future of the library!
