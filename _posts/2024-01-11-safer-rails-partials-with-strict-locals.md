---
title: Safer Rails partials with strict locals
date: 2024-01-11
description: Rails 7.1 introduced strict locals which we can use to make our partials safer and easier to work with.
---

How many times have you seen this error message in your Rails app?

```
undefined local variable or method `title' for #<ActionView::Base:0x0000000001b3f0>
```

If this error is being raised from a partial then chances are you forgot to pass in a local variable.

Rails 7.1 added a new feature that can completely remove these issues from our codebase. Let’s explore how *strict locals* can make our Rails partials **safer** and **easier** to work with.

## Rails partials

Rails partials are a great way to break up complex UI into smaller and easier to work with components. They help reduce the context you need to keep in your head at any given time.

It’s nice to keep verbose styles in a single file, especially when working with Tailwind CSS. Here’s an example of how you might build a badge element.

```erb
<%# app/views/shared/_badge.html.erb %>

<span class="text-sm font-medium bg-blue-100 text-blue-800 px-2.5 py-0.5">
  <%= title %>
</span>
```

Anywhere in your codebase you can now render this via:

```erb
<%= render "shared/badge", title: "NEW" %>
```

This partial expects a single local variable to be defined, `title`.

But what happens if you forget it pass it along?

```erb
<%= render "shared/badge" %>
```

You get an error message pointing to the line where the variable was first accessed, *in the partial*. It’s our responsibility to climb up the backtrace and figure out exactly where we forgot to assign that variable.

![Default error message](/assets/images/safer-rails-partials-with-strict-locals/default-error-message.png){:standalone}

## Strict locals

We can avoid this issue with *strict locals*. Introduced way back in [2022](https://github.com/rails/rails/pull/45602) but only first available in Rails 7.1, this magic comment defines which variables our partial expects.

```erb
<%# app/views/shared/_badge.html.erb %>
<%# locals: (title:) %>

<span class="text-sm font-medium bg-blue-100 text-blue-800 px-2.5 py-0.5">
  <%= title %>
</span>
```

`locals:` lets Rails know we are defining the variables. You can think of what’s inside the parenthesis as arguments to a Ruby method. Here, we expect `title:` to be passed in.

If we don’t pass in all the expected variables we get a much cleaner error message.

![Strict partials error message](/assets/images/safer-rails-partials-with-strict-locals/strict-locals-error-message.png){:standalone}

We immediately see where in the *calling code* we forgot to pass the local variable! We don’t have to dive into the stack trace; **we know exactly what line of code to change**.

## Default arguments

Another benefit of *strict locals* is the option to set default arguments. Defining a value for a variable makes it optional and not required by the calling code. Just like a Ruby method!

```erb
<%# app/views/shared/_badge.html.erb %>
<%# locals: (title: "NEW") %>

<span class="text-sm font-medium bg-blue-100 text-blue-800 px-2.5 py-0.5">
  <%= title %>
</span>
```

Now, `title` will be set to `"NEW"` unless we override it in the calling code.

This is perhaps my favorite part of *strict locals*. What used to be a mess of Ruby code in our views boils down to a single line of code that is much easier to understand.

Here’s what that might have looked like before. 😵‍💫

```erb
<%# app/views/shared/_badge.html.erb %>
<% title = local_assigns[:title] || "NEW" %>

<span class="text-sm font-medium bg-blue-100 text-blue-800 px-2.5 py-0.5">
  <%= title %>
</span>
```

**This technique has reignited my love for Rails defaults like partials.** I still think View Components have their place. But for views light on logic, *strict locals* with default arguments are an excellent alternative.

Have you experimented with *strict locals* in your Rails app? How are you liking them? Let me know on Twitter!
