---
title: Redirect www traffic to a naked domain in Rails
date: 2020-11-26
description: A single Rails route gets you what you need, but watch out for a small gotcha.
---

Naked domains, or root domains, are hosts without the leading `www`. This blog is a perfect example, `masilotti.com`. They are more succinct, direct, and easier to read.

If you set this up it’s also important to redirect `www` to the naked domain. Without the redirect, Rails might set up separate cookies for the two domains. So someone signed in on `www.example.com` might not be on `example.com`.

## A single Rails route

In Rails, you can redirect the `www` traffic with a single redirect in your routes configuration.

```ruby
match "(*any)",
  to: redirect(subdomain: ""),
  via: :all,
  constraints: { subdomain: "www" }
```

Broken down:
* `match "(*any)"` - matches any path to the site
* `to: redirect(subdomain: "")` - removes the subdomain, in this case `www`
* `via: :all` - matches all HTTP verbs (GET, POST, PUT, etc.)
* `constraints: { subdomain: "www" }` - only match requests that start with `www`

It’s important to note that this must be the first line in the file. At a high level, Rails goes down the list to find a match. If something matches the request gets routed. Keeping this at the top ensures it happens before anything else.

## Naked domains on Heroku

Before you convert your site to a naked domain make sure your domain registrar and DNS provider works with `ALIAS` or `ANAME` DNS records.

> …Since Heroku uses dynamic IP addresses, it’s necessary to use a CNAME-like record (often referred to as ALIAS or ANAME records) so that you can point your root domain to another domain… - [Heroku docs](https://devcenter.heroku.com/articles/custom-domains#configuring-dns-for-root-domains)

Their list of approved DNS providers is limited. Hover, for example, doesn’t support these types of records. I ended up migrating to [namecheap](https://www.namecheap.com).
