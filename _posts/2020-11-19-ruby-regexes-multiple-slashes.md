---
title: Regexes with multiple slashes in Ruby
date: 2020-11-19
description: A tiny tip to make regexes with multiple slashes a bit more readable in Ruby.
---

I picked up a new tip yesterday while working with regexes in Ruby. I was testing if a string begins with `http://` or `https://` and wrote a small regex.

```ruby
/^https?:\/\//
```

Broken down, this ensures the string:

1. Starts with `http`
2. The next character is optionally `s`
3. The next characters are  `://`

Even for such a simple regex that feels a bit hard for me to read. There are too many escaped slashes for my taste.

To improve this a bit you can use `r%{}` over `/.../`. The syntax works the same but you don’t need to escape slashes.

The regex becomes something much more readable:

```ruby
%r{^https?://}
```

GitHub's RuboCop styleguide has a recommendation on when to use this syntax.

> Use `%r` only for regular expressions matching *more than* one `/` character. - [RubuCop Ruby Style Guide](https://github.com/github/rubocop-github/blob/master/STYLEGUIDE.md#regular-expressions)

P.S. I could have probably just used two `#starts_with?` calls but where’s the fun in that?
