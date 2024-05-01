---
title: "Rails Authentication: Gems vs. Recipes vs. Generators"
date: 2024-05-06
description: "Three different ways to handle authentication in Rails: from quick gem installs to custom-built recipes and flexible generators."
---

I recently asked what folks are using for authentication in their Rails apps [on Twitter](https://x.com/joemasilotti/status/1785666667449872420). And as expected, I got a *lot* of different responses. But they all fit into three categories: gems, recipes, and generators.

Here’s how these three approaches compare and contrast with each other. While writing this I learned about a few techniques that I can’t wait to try in the future - hopefully you will, too.

## 💎 Gems

Perhaps the most obvious choice of the three, reaching for a gem is almost second nature for Rails developers.

[Devise](https://github.com/heartcombo/devise), [clearance](https://github.com/thoughtbot/clearance), [Rodauth](https://github.com/janko/rodauth-rails), and others provide battle-tested solutions for authenticating users. They often handle most, if not all, of your authentication needs like password reset flows, email confirmations, and more. And there’s gems with smaller scopes like [passwordless](https://github.com/mikker/passwordless) and [nopassword](https://github.com/rubymonolith/nopassword) for authenticating users without a password.

Installation can be as straightforward as adding the gem to your Gemfile and providing a configuration file. This means you can check authentication off your to-do list and move on to more important features.

Using a tried-and-true gem also means you get years of community support documented in GitHub Issues or wikis. Chances are that if you’re trying to do something that someone else already did it before.

And security updates? Often as simple as updating your Gemfile!

But using gems often comes with a price. Customizing functionality or user flows can often prove difficult. Adding multifactor authentication, passwordless sign in, API tokens… sometimes it can feel like you’re fighting the code instead of shaping it.

I’ve had to add [Turbo Native]({% post_url 2024-03-28-turbo-native-apps-in-15-minutes %}) authentication to Devise more times than I can count. And I *always* have to look up how to properly subclass `Devise::SessionsController` to handle requests a bit differently when coming from the hybrid apps.

If you have a lot of customizations to make or want more ownership and control of your entire codebase then rolling your own authentication might serve you better.

## 📝 Recipes

[Rails 7.1 introduced new APIs](https://rubyonrails.org/2023/10/5/Rails-7-1-0-has-been-released#build-your-own-authentication-improvements) that make rolling your own authentication more viable. `has_secure_password`, `authenticate_by`, and `generates_token_for` work together to provide the building blocks for securely authenticating users across your system.

These additions mean you can build custom without having to worry about every little detail under the hood. [Rails Authentication From Scratch](https://stevepolito.design/blog/rails-authentication-from-scratch) from Steve Polito and [Rails 7.1 Authentication From Scratch](https://gorails.com/episodes/rails-7-1-authentication-from-scratch) from GoRails are great places to start if you go down this path.

I’m a big fan of this approach - especially for apps with less complex requirements. All of the authentication code in Daily Log is only [42 lines](https://github.com/joemasilotti/daily-log/blob/main/rails/app/controllers/concerns/authentication.rb)!

And building your own authentication from scratch can get as feature-rich as you need. For example, take the [ReviseAuth](https://github.com/excid3/revise_auth) gem, “a pure Rails authentication system like Devise.” This uses the new 7.1 APIs while adding all the features you expect from a full authentication solution. Even if you don’t use the gem directly, reading through this code could help with architectural decisions in your own implementation.

Rolling your own authentication can require a fair amount of work to build all the features you need. So if you’re looking for something in between a gem and fully custom solution then a generator might be a better fit.

## 🤖 Generators

A generator is a fancy way of saying “copy and paste this code into my app”.

You get the benefits of battle-tested code while also having *full* control over every little detail. Changing user flows or adding features is often easier than using a gem because you can dive in and change whatever code you want.

But you might not even need to. [Authentication Zero](https://github.com/lazaronixon/authentication-zero), a popular authentication generator for Rails, provides a huge feature list out of the box. And you can flag each feature on or off when running the script to generate your perfect system.

However, with more control comes more responsibility. Taken from the docs, *you* are required to manually update your code if you want new features or security fixes (emphasis mine).

> The one caveat with using a generated authentication system is **it will not be updated after it's been generated**. Therefore, as improvements are made to the output of `rails generate authentication`, it becomes your responsibility to determine if these changes need to be ported into your application. Security-related and other important improvements will be explicitly and clearly marked in the `CHANGELOG.md` file and upgrade notes.
> 

I’m excited to experiment with generators more in the future, especially because one is on the roadmap for [Rails 8](https://github.com/rails/rails/issues/50446). But as with most first versions of new Rails features, the generator will probably be relatively minimal and only cover basic use cases.

What about you? What gem or approach are you using *now*? And if you could wave a magic want… what gem or approach do you *wish* you were using?
