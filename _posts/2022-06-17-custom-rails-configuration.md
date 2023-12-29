---
title: Custom Rails configuration
date: 2022-06-17
description: TIL about ActiveSupport::OrderedOptions and config_for. Here's how I'm using them to configure my Rails app.
---

The Rails apps I work with have varying levels of configuration. Some require credentials files while others shove a few variables in `application.rb`. There are applications using  `.env` and some with constants littered across the codebase.

But there’s one common thread. They all require some environment-based configuration that _isn’t_ secret. Configuration that doesn’t change often but is used throughout the codebase. Stuff we don’t mind checking in to source control.

I started using [`ActiveSupport::OrderedOptions`](https://api.rubyonrails.org/classes/ActiveSupport/OrderedOptions.html) to configure a few variables in my Rails app. I like how the API gives me clean, explicit, and fail-fast feedback. Also, it’s built into Rails!

Let’s walk through different ways of adding custom configuration to a Rails app. We will use email addresses in our examples.

## Basic configuration

For single variables that are constant across environments you can add a variable directly to your Rails application file. Here I’m adding a support email address to be used in my mailers and the public support page.

```ruby
# config/application.rb`

module MyApp
  class Application < Rails::Application
    config.support_email = "joe@masilotti.com"
  end
end
```

Attaching configuration directly to the application is the most straightforward approach. It can be accessed directly, as well.

```ruby
Rails.configuration.support_email # => "joe@masilotti.com"
```

You can also override these values in the environment specific configuration files like `config/environments/development.rb` and `production.rb`.

## Nested configuration

You can nest configuration to associate a few values under a single namespace. In this example I have two email addresses, one for support and one for marketing.

```ruby
# config/application.rb`

module MyApp
  class Application < Rails::Application
    config.x.emails.support = "joe@masilotti.com"
    config.x.emails.marketing = "hi@masilotti.com"
  end
end
```

Accessing them follows the same approach as above, the addition of the `x`.

```ruby
Rails.configuration.x.emails.support # => "joe@masilotti.com"
Rails.configuration.x.emails.marketing # => "hi@masilotti.com"
```

## More complex configuration

This works great for a few variables. But what happens when you have 15 email addresses to configure? And they are all different based on the environment? All those lines of code would only muddy up  `application.rb`.

Enter `Rails::Application.config_for`, a helper method to load entire configuration files. Here’s how it works.  First, create a YAML file holding all of your configuration.

```yaml
# config/emails.yml

shared:
  support: joe@masilotti.com
  marketing: hi@masilotti.com
  # Many more email addresses...
```

Next, load the file with `config_for` in your application file.

```ruby
# config/application.rb

module MyApp
  class Application < Rails::Application
    config.emails = config_for(:emails)
  end
end
```

You can now access these values like before. And without the additional `x`.

```ruby
Rails.configuration.emails.support # => "joe@masilotti.com"
Rails.configuration.emails.marketing # => "hi@masilotti.com"
Rails.configuration.emails.sales # => nil
```

Oh, wait a minute. Why did `#sales` return `nil`? Shouldn’t a missing value raise an exception or something?

### Raise on `nil` values

Glad you asked! Add a bang at the end of the call and Rails will raise an error if the value doesn’t exist.

```ruby
Rails.configuration.emails.sales! # => KeyError: :sales is blank
```

### Environment-specific configuration

The YAML file can also be extended to provide environment-specific configuration. Note the `shared:` key at the top? That will apply across all environments. But providing environments as keys will override the shared values.

```yaml
# config/emails.yml

shared:
  support: joe@masilotti.com

production:
  support: support@masilotti.com
```

Now, in development we will get `joe@masilotti.com` but in production `support@masilotti.com`. No changes are needed to `application.rb`.

More information on Rails configuration can be found in the [Configuring Rails Applications](https://guides.rubyonrails.org/configuring.html#custom-configuration) guide.

## Real world example

I’m using this in production on [RailsDevs, my open source Rails app](https://github.com/joemasilotti/railsdevs.com). I have a few email addresses configured and pull them in on support pages and mailers.

It works really nice for Rails configuration that changes infrequently, might differ across environments, and doesn't need to be kept secure. Keeping these directly in the codebase makes onboarding new developers to the OSS project easier.
