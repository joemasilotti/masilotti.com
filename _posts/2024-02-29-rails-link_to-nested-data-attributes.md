---
title: Rails link_to and nested data attributes
date: 2024-02-29
description: "A cleaner, easier to read approach to nested data attributes for Turbo and Strada when creating anchor tags in Rails."
---

The `link_to` helper in Rails creates an anchor element, the `<a>` tag. It accepts an optional block and three parameters: the name of the link, an options hash, and an HTML options hash.

In Turbo, adding `data-turbo-confirm` to the helper can be used to request confirmation from the user before submitting a form. This presents a native browser `confirm()` dialog before deleting the blog post.

Here's how you could prompt the user before deleting a blog post:

```erb
<%= link_to "Delete post", post_url(@post),
  class: "btn btn-outline-primary", 
  "data-turbo_method": "delete",
  "data-turbo-confirm": "You sure?" %>
```

As I was writing the Strada chapter for [my upcoming book on Turbo Native]({% link _pages/book.liquid %}) I stumbled across something exciting. I needed to write a fairly complex `link_to` component that had multiple, nested Strada attributes.

**I discovered that there’s a more Ruby-friendly way to write data attributes.** And in my opinion, the approach is a bit cleaner and easier to read.

Dashes are great but they require wrapping the key in quotes, as shown above. Ideally, we would be able to use underscores, like so:

```erb
<%= link_to "Delete post", post_url(@post), 
  class: "btn btn-outline-primary",
  data_turbo_method: "delete",
  data_turbo_confirm: "You sure?" %>
```

Unfortunately, underscores won't work with Turbo and don’t generate the same HTML output.

```html
<a class="btn btn-outline-primary"
  data_turbo_method="delete"
  data_turbo_confirm="You sure?"
  href="#">Underscores</a>
```

But what if we nest the `data` attributes as a hash?

```erb
<%= link_to "Delete post", post_url(@post), 
  class: "btn btn-outline-primary", data: {
    turbo_method: "delete",
    turbo_confirm: "You sure?"
  } %>
```

This produces the same output as our first example, `data-turbo-method` and `data-turbo-confirm`. I like this approach better for two reasons:

1. Not seeing `data` for every attribute makes it a bit easier to read.
2. We can still grep for “turbo_method” across our codebase.

But what if we wanted to go… deeper? Let’s see what happens when we nest the `turbo` attributes as well.

```erb
<%= link_to "Delete post", post_url(@post), 
  class: "btn btn-outline-primary", data: {
    turbo: {
      method: "delete",
      confirm: "You sure?"
    }
  } %>
```

This produces the following HTML:

```html
<a class="btn btn-outline-primary"
  data-turbo="{&quot;method&quot;:&quot;delete&quot;,&quot;confirm&quot;:&quot;You sure?&quot;}"
  href="#">Deeply nested</a>
```

Oh dear, that certainly didn’t work! It looks like `link_to` tried to convert this to JSON and then escape it before writing the HTML. Unfortunately, that won’t work for Turbo or Strada.

For now, I’ll be sticking with a single-level `data` hash. What about you? Which approach do you use in your Rails apps?
