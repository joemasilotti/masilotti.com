---
title: "Hybrid iOS apps with Turbo – Part 3: Forms and basic authentication"
date: 2021-03-19
description: How to install Turbo in Rails 6, custom iOS form handling, and web-based authentication in hybrid apps.
series: turbo-ios
series_title: Forms and basic authentication
---

{% include warning.liquid %}

This is part 3 of a [6-part series on Hybrid iOS apps with Turbo]({% post_url 2021-05-14-turbo-ios %}). We kicked off with an [introduction to the Turbo framework]({% post_url turbo-ios/2021-02-18-hybrid-apps-with-turbo %}) and touched on why hybrid can be a great choice. Part 2 dove into [URL routing with Turbo]({% post_url turbo-ios/2021-02-26-url-routing %}) and how to get your path configuration set up.

{% include series.liquid %}

This article focuses on two major components of hybrid app development: forms and authentication. We will also migrate from Basecamp’s example app to a real Rails app as examples to illustrate the points discussed. Let’s dive in!

## Turbo installation

If you’re running Ruby on Rails 6.1+ with Turbo (v7) installed you can [skip this part](#basic-crud).

### Step 0: Upgrade to Rails 6.1

This is technically optional, but the rest of this article assumes you are using Rails 6.1. This release [generates non-remote forms by default](https://github.com/rails/rails/pull/40708). This means no AJAX or JavaScript, regular old HTTP forms.

The PR has more details on how to make this the default configuration for earlier versions of Rails.

### Step 1: Install `turbo-rails`

The `turbo-rails` gem adds the Turbo JavaScript and some additional helpers to your Rails application. Most importantly, it intercepts form submissions to respond with Turbo streams.

Following the [instructions from the README](https://github.com/hotwired/turbo-rails#installation):

1. Add `gem ‘turbo-rails’` to your Gemfile
2. Run `bundle install`
3. Run the generator with `rails turbo:install`

### Step 2: Wire up the JavaScript

If you are using webpack(er), you can add the following to the end of your JavaScript pack. This imports the framework and exposes it to native adapters.

```javascript
import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo
```

Now is a good time to audit your app for any references to Turbo_links_. Most of the upgrade can be done with a find-and-replace and [Go Rails has a free video with more details](https://gorails.com/episodes/upgrade-from-turbolinks-to-hotwire-and-turbo).

## Basic CRUD

You can now start pointing your iOS app to your Rails server. If Turbo is configured you should be able to navigate around and tap through links.

<p class="note">Don't have a Turbo iOS app yet? The <a href="{% post_url 2021-05-14-turbo-ios %}">first two parts</a> of this series build one from scratch! Or, feel free to <a href="https://github.com/joemasilotti/Turbo-iOS-Demo">download the source directly</a>.</p>

To demonstrate how well Turbo works out of the box, I’m using the default Rails scaffolding generator. This creates the route, database migration, ActiveRecord model, controller, and views.

```
rails generate scaffold BoardGame name:string players:integer
```

Run this command, migrate your database with `rails db:migrate`, and visit [http://localhost:3000/board_games](http://localhost:3000/board_games) in your browser. You can view, create, edit, update, and destroy board games.

Even better, open the iOS app. Everything should work there, too! This is because Turbo (not Turbolinks) now handles form submissions entirely - no need for custom JavaScript to get everything working.

## Validations and invalid forms

However, there is one thing we need to handle manually. Open up the `BoardGame` model and add a validation. For example, that `name` has to be present.

```ruby
class BoardGame < ApplicationRecord
  validates :name, presence: true
end
```

Submitting the form without a name will generate a flash message in your browser. Standard Rails stuff.

![Standard Rails flash message.](/assets/images/turbo-ios/forms-and-basic-authentication/flash-message-web.png){:standalone}

But try the same in the iOS app. The submit button gets disabled but then that’s it. Nothing else happens. What gives?

![iOS form with the submit button disabled, but it doesn't seem to have actually submitted.](/assets/images/turbo-ios/forms-and-basic-authentication/broken-form-ios.png){:standalone .unstyled.max-w-xs}

From the generator, our controller re-renders the "new" view if the board game is invalid. By default, this sets the response status code as 200 OK.

```ruby
def create
  @board_game = BoardGame.new(board_game_params)

  if @board_game.save
    redirect_to @board_game, notice: 'Board game was successfully created.'
  else
    render :new
  end
end
```

The Turbo JavaScript doesn’t know what to do with a `200 OK`. Instead, we can let the framework know something went wrong by giving it [anything in the 400 or 500 range](https://twitter.com/dhh/status/1346448749170749449?s=20); `422 Unprocessable Entity` works great.

```ruby
render :new, status: :unprocessable_entity
```

## Double pushed controllers

Now that forms are working you might notice a different issue. If you view then edit a board game, you end up with two "show" controllers on the navigation stack.

This is occurring because our `redirect_to` is coming down the wire as `VisitAction.advance`, which always pushes a new controller.

We can fix this by overwriting the `.advance` action. If we are being redirected to the same URL we are already viewing then perform a `.replace` instead.

```swift
let action: VisitAction = url ==
  session.topmostVisitable?.visitableURL ? .replace : action
```

## Turbolinks form submissions

There’s a bit more work if your server hasn’t migrated to Turbo (v7) and is still using Turbolinks (v5). We no longer have access to all of that generic form handling JavaScript so we are forced to write our own.

My client and I have generalized most of this work into a single Stimulus controller and corresponding View Component. The component takes in the name of the partial to re-render and the controller hooks into the AJAX form submission.

The bones of the approach listens for the `ajax:error` event. When fired, the form is re-rendered. While naive, it goes a long way in keeping the amount of custom JavaScript low while you migrate to Turbo.

```javascript
import { Controller } from "stimulus"

export default class extends Controller {
  onError({ detail: [data, , xhr] }) {
    this.element.innerHTML = xhr.response;
  }
}
```

```erb
<%= form_with(model: board_game, local: false, data: {
  controller: "form",
  action: "ajax:error->form#onError"
}) do |form| %>
  <%# ... %>
<% end %>
```

## Basic authentication

The Turbo-iOS repo outlines [a few approaches to authentication](https://github.com/hotwired/turbo-ios/blob/main/Docs/Authentication.md). Cookie-based authentication, which relies on the web view for session management, requires very little work. Native authentication is much more in depth, but has a few key benefits.

### Cookie-based authentication

Many hybrid apps can get by with this approach. In short, you let the web view internally manage the cookies and session. There are, however, two gotchas.

First, the authentication cookie must never expire. It would feel very un-native to have to sign back in to an app every two weeks! If you are manually setting cookies in Rails you can use the `permanent` helper.

```ruby
cookies.permanent.signed["user_id"] = current_user.id
```

> `#signed` sets a signed cookie, which prevents users from tampering with its value. The cookie is signed by your app’s `secrets.secret_key_base` value. It can be read using the signed method `cookies.signed[:name]`. - [ActionDispatch::Cookies < Object](https://api.rubyonrails.org/v5.1.7/classes/ActionDispatch/Cookies.html)

With Devise you need to make two changes: one to your `User` model and the other to the Devise configuration.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  def remember_me
    (super == nil) ? '1' : super
  end
end

# config/initializers/devise.rb
Devise.setup do |config|
  config.remember_for = 20.years
end
```

These changes ensure the user is always remembered "forever." 20 years is what Rails uses for [permanent cookies](https://apidock.com/rails/ActionDispatch/Cookies/CookieJar/permanent). You might also want to hide the "Remember me?" option in the sign in form.

### Client changes

We need to do very little to get this to work on the client. Since we are [routing `/new` paths to a modal controller]({% post_url turbo-ios/2021-02-26-url-routing %}), the sign in form already looks great. Signing in closes the modal and pushes or replaces a new page.

However, we don’t seem to be signed in on that newly loaded page. What gives?

Turns out, each `Session` uses a distinct web view. And each `WKWebView` has its own cookie jar. We can tell them to share cookies with each other by initializing them with the same `WKProcessPool`.

```swift
let sharedProcessPool = WKProcessPool()
let configuration = WKWebViewConfiguration()
configuration.processPool = sharedProcessPool

let mainSession = Session(webViewConfiguration: configuration)
let modalSession = Session(webViewConfiguration: configuration)
```

### Native authentication

One major limitation of web-only authentication is, well, its web only. That limits us to only interacting with our server via HTML and JavaScript. You’re out of luck if you need to make an authenticated HTTP request. And since those usually power the interesting native screens, those are off the table, too.

Native authentication in a hybrid app follows this rough outline:

1. Present a native sign in screen
2. Sign in via a secure HTTP request
3. Receive an authentication token for future requests
4. Pass that token to the web view to persist the cookies

I’ve been doing some heavy thinking on this and have implementation recommendations. These will be discussed in the "native screens" article of this series.

Can’t wait? Here’s a sneak peek of what I will be covering.

1. A native sign in screen powered by SwiftUI
2. JWT-based auth via the [API Guard](https://github.com/Gokul595/api_guard) gem
3. Parsing the `Set-Cookie` HTTP header response and passing the cookies to the web view

*Really* can’t wait? Feel free to [send me an email](mailto:joe@masilotti.com) if you’d like 1:1 help.

## Up next: The JavaScript bridge

Now that forms and basic authentication are out of the way we can dive into more exciting Turbo-iOS features.

The next article [in the series]({% post_url 2021-05-14-turbo-ios %}) will cover the JavaScript bridge - this is how we send messages between Rails and iOS without HTTP requests. I use the bridge to trigger native actions, render native controls, register push notification tokens, and lots of other fun stuff.

If you’re following along with the series I’d love if you could share it with another developer! As always, feel free to [reach out on Twitter](https://twitter.com/joemasilotti) or [via email](mailto:joe@masilotti.com) if you have any questions.
