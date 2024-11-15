{% include workshop/cta.liquid %}

{% assign testimonial = site.data.workshop.testimonials["mike"] %}
{% include testimonial.liquid object=testimonial %}

As a Rails developer, Turbo Native is your shortcut to creating native apps. It lets you code once and deploy everywhere, using mobile web views in native frames.

The problem? The official docs are sparse and there aren't many examples out there.

## What you'll get out of this workshop

You'll learn everything you need to know to get started with Turbo Native on iOS:

{% comment %} TODO: Revamp workshop agenda for Hotwire Native. {% endcomment %}

1. **Turbo Native** - Steps to integrate the framework into a Xcode project.
1. **Navigation** - Add Turbo Navigator to handle the important navigation flows.
1. **Progressive enhancement** - Uncover hidden Rails helpers to work with native.
1. **Authentication** - Ensure users remain signed in between launches.
1. **Native components** - Use Strada for Swift components driven by HTML.

{% assign testimonial = site.data.workshop.testimonials["miles"] %}
{% include testimonial.liquid object=testimonial %}

## Format

The 2-hour session combines live coding with hands-on exercises.

There'll be a short break and a Q&A session at the end.

## Extras

You'll also get:

* **iOS + Rails codebases** - The groundwork for launching your own Turbo Native app.
* **Turbo Native community** - Access to a Discord server to discuss Turbo Native.

## Register

{% include workshop/cta.liquid %}

{% assign testimonial = site.data.workshop.testimonials["sweta"] %}
{% include testimonial.liquid object=testimonial %}

## About the author

I'm Joe, your Turbo Native guide since 2015. I've helped businesses go live on the App Store and I'm excited to share my expertise with you.

Question about the workshop? [Send me an email](mailto:joe@masilotti.com).

## Prerequisites

You need to run Ruby on Rails and Xcode, clone git repos, and know very basic Swift. Brush up on [Swift for Ruby developers]({% post_url 2023-04-25-swift-for-ruby-developers %}) if needed.
