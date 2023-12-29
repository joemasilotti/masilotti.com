---
title: Zero to Tailwind CSS over the weekend
date: 2020-07-24
description: How I built a landing page and redesigned my blog in Tailwind CSS over the weekend. And why I’ll never go back.
---

This past weekend, I built [a landing page](https://xwing.app) and redesigned this blog with Tailwind CSS. Getting going was tough. But I don't think I'll ever go back.

Oh, and both the [landing page](https://github.com/joemasilotti/x-wing-ai-tailwind) and [Masilotti.com](https://github.com/joemasilotti/masilotti.com-tailwind) are now open source!

![Screenshot of the X-Wing AI landing page](/assets/images/tailwind-css/xwing.app.png){:standalone}

## What the h*ck is Tailwind?

> [Tailwind](https://tailwindcss.com) is a CSS framework for people who hate CSS frameworks. - Joe Masilotti

Tailwind takes an unopinionated approach to design and leaves everything in your control. Instead of being tied to, say, Twitter Bootstrap’s card design, you build yours from scratch with Tailwind.

And from someone who usually hates working with CSS, it's actually quite enjoyable.

## Another CSS framework?!

Yes. And no. But mostly yes.

Tailwind’s unique approach focuses on utility classes to build everything. Instead of given components like headers, heroes, or cards, you instead use tiny little classes that do a single thing.

`mr-4` adds a bit of **m**argin to the **r**ight. `bg-gray-200` sets the background color to a very light gray. And `flex` sets the display property.

Combining these with size class modifiers enables very powerful styling with very little code. All classes apply to all size classes until you prefix them. `md:max-w-xl` sets the max width to extra large but only on medium and larger devices. `lg:h-16` sets the height on large (and larger) devices. While a plain `pl-16` will set a **l**eft **p**adding on all sizes.

```html
<div class="mx-4 md:mx-8 lg:mx-16 bg-teal-200"></div>
```

This snippet will have an increasingly bigger horizontal margin as the screen size is increased. And all will use this light teal background color.

### ~~Cascading~~ stylesheets

![Waterfall with a cross through it](/assets/images/tailwind-css/cascading-stylesheets.png)

Another goal of Tailwind is to make it easier to deal with large CSS codebases.

Changing a global style too often cascades across multiple widgets, components, pages, or templates. (Or you miss a part of the selector chain and nothing happens.) With Tailwind, those changes are scoped only to the HTML element to which they are applied.

In practice, this means you can tweak the layout of your blog without having it mess up your landing page. Enforcing changes that are more direct and easier to reason about.

## Configuration over convention

A major goal of Tailwind is to write less CSS. Take a second and let that one sink in. A CSS framework that wants you to write less CSS. Crazy!

As shown above, you create custom styles by combining long chains of utility classes. You don't create global "hero" components that end up getting customized each time they are used anyway.

On Masilotti.com I have no custom CSS. Zero. Everything comes from Tailwind utility classes and some basic configuration.

This takes out the biggest gripe I have with CSS, maintaining it. You don't have to maintain something if it doesn't exist in the first place!

## So, how does it all work?

Another differentiating factor of Tailwind is *how* it’s built. If you grab the latest from the CDN, you’ll notice the file is quite large. And there’s a *ton* of stuff you will never use. Tailwind has a surprisingly elegant solution for this.

First, all of the custom Tailwind is run through a preprocessor, usually PostCSS. This does all the fancy iterating and looping to create every single combination of screen size, property, attribute, modifier, etc. That’s why the CDN file is so large.

The second phase (hint: where the magic happens) is done with CSS purging. This step removes all of CSS classes that aren’t being used in your project. These reductions can be *ginormous*. A smaller bundle means a smaller payload and easier parsing for the web. Faster load times means happier customers!

## With great power comes great responsibility

!["With great power comes great responsibility" - Spiderman](/assets/images/tailwind-css/spiderman.png){:standalone}

Tailwind gives you the flexibility to create anything you want. Like, literally anything. Take a peek at their CSS reset, [Preflight](https://tailwindcss.com/docs/preflight/). It even resets the font size of heading tags!

To compare, Twitter Bootstrap makes it really easy to create something that looks *fine*. Throw a grid up, slap some cards in place, maybe tweak the hero, and boom. You have something that functions and doesn’t look too terrible.

Tailwind, out of the box, looks like entirely unstyled HTML. And it takes a bit of work to get it looking decent. But the investment pays for itself very quickly.

To work around this I've adopted the official [typography](https://tailwindcss.com/docs/preflight/) plugin. Install it and wrap blocks of prose in a `prose` class for very sensible defaults. This content of Masilotti.com is 99% styled with the `typography` plugin.

## Building Tailwind

OK, great, you’re convinced. "Let’s do Tailwind!" I can hear you yelling at your monitor. But how? …great question.

For all my praise, Tailwind is still a pain in the butt to build. Because of its complex build process (relative to Bootstrap) it requires a bit of modern web packaging know-how.

There are more than a few ways to get Tailwind integrated into your build process. I’ll touch on the two that I dove into this weekend. There’s also plenty of [official example setups on GitHub](https://github.com/tailwindlabs/tailwindcss-setup-examples).

### Static HTML site

My first goal with Tailwind was building a [static HTML landing page](https://xwing.app). This let me dive into manually setting up the build process along with all of the CSS processing.

I ended up with a fairly standard configuration and two custom yarn scripts to help with watching during development and deploying for production.

```javascript
// package.json
{
  // ...
  "scripts": {
    "build": "copyfiles --up 1 'src/**/*' dist && postcss css/base.css -o dist/css/styles.css --env production",
    "watch": "postcss css/base.css -o src/css/styles.css --watch"
  }
  // ...
}
```

```javascript
// postcss.config.js
module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss'),
    require('autoprefixer'),
    process.env.NODE_ENV === 'production' && require('@fullhuman/postcss-purgecss')({
      content: [
        './dist/index.html',
      ],
      defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
    }),
    process.env.NODE_ENV === 'production' && require('cssnano')({
      preset: 'default'
    })
  ]
}
```

`yarn run watch` processes my source CSS and spits it out to be linked in the HTML file. Appending `--watch` ensures that `postcss` continues to build while files are updated.

 `yarn run build` copies everything from `src/` and moves it to `dist/` then processes, purges, and minifies the CSS. I can then deploy the contents of `dist/` to production.

Was it worth doing manually? Yes. Would I do it again? No.

It was worth learning how the sausage was made but only once. In the future I would copy this over from an old project instead of creating it from scratch.

P.S. The site is [open source](https://github.com/joemasilotti/x-wing-ai-tailwind).

### Jekyll and Tailwind

This site is built with [Jekyll](https://jekyllrb.com), a static site generator written in Ruby. I based the project on [jekyll-tailwind-starter](https://github.com/mhanberg/jekyll-tailwind-starter) and customized to my liking.

I don’t think I can recommend using this repo. There are better ones on the official site. Things were a little out of date but the scaffolding was there.

That said, the repo did get me where I needed to be. It has all of the standard CSS processing built in and integrated with Jekyll’s build scripts. All I have to do is run `bin/start` and it watches for changes. It even hooks up `live-reload` so I don’t have to refresh the page!

```bash
bundle exec jekyll serve --livereload --drafts --future --port 3000 --livereload_port 35729 "$@"
```

[This site is open source](https://github.com/joemasilotti/masilotti.com-tailwind) so feel free to poke around!
