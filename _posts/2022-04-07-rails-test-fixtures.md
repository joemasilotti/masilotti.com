---
title: My sane approach to test fixtures in Rails
date: 2022-04-07
description: My approach on how I keep my test fixtures manageable, sane, and obvious. Not hard and fast rules, but guidelines to help you implement the same in your app.
---

I’ve been an RSpec/FactoryBot fan for a long time. Getting my Rails career started at Pivotal Labs we spent a lot of time TDDing with behavior-focused tooling.

But since staking out on my own 2+ years ago I started to work with clients using minitest and test fixtures. I’ll admit, at first I hated the change. Minitest felt so limiting; and I couldn’t wrap my head around having all of my test permutations predefined.

Fast forward a few years and I’ve built up a [sustainable business](https://railsdevs.com/open) powered by [an open source Rails app](https://github.com/joemasilotti/railsdevs.com/). Being open source, my goal is to use as many of the Rails defaults as possible - that means minitest and fixtures.

So, as projects tend to go, things grew. And test fixtures exploded. At one point there were [20+ different fixtures just for the `User` model](https://github.com/joemasilotti/railsdevs.com/blob/78c2c01c6ea1f87e776c45506346825bad60234e/test/fixtures/users.yml). It had gotten to the point where you had to understand the entire fixture dependency graph just to test something. Not good!

So I set off to reduce the number of fixtures used in the app. But, as these things tend to do, this [snowballed into a 1000+ line diff](https://github.com/joemasilotti/railsdevs.com/pull/366) focused entirely on refactoring the test suite.

That refactor taught me a lot on how to manage my Rails test fixtures. Here’s my approach on how I keep my fixtures manageable, sane, and obvious. These aren’t hard and fast rules, but guidelines to help you implement the same in your app.

1. 1-2 default fixtures per model
2. Customize bespoke fixtures in the test suite
3. Extract helpers for common customizations
4. Add additional fixtures only when dependencies are complex

## #1: 1-2 default fixtures per model

Perhaps the most obvious of the guidelines: the fewer fixtures you have to manage the easier it is to write tests. My approach here is to have a single fixture with boring, sane, default attributes. Don’t try and tease out different permutations - stick with fixtures that are valid and have as few dependencies as possible.

 I reach for a second fixture when I need to compare two models of the same class. The second fixture also has boring, sane default attributes but with slightly different values to distinguish it from the first.

I name these `:one` and `:two`, respectively. They don’t have anything “special” about them. They are serving as two instances, nothing more.

Here’s an example of a `Developer` fixture from my app. The values are obvious and make it clear this is `developers(:one)` when running the tests. And the only relationship is to the `User`, which is a validation requirement.

```ruby
# test/fixtures/developers.yml

one:
  user: developer
  name: Developer One
  available_on: <%= Date.new(2021, 1, 1) %>
  hero: Developer number one
  bio: I am the first developer.
```

## #2: Customize bespoke fixtures in the test suite

But what happens when I need to test something that `developers(:one)` can’t handle? Say, a query for developers with specific `available_on` dates?

Before I would add a new fixture with a different attribute. But this is exactly what got me into the problem in the first place! Instead, we modify the existing fixtures _in the tests_. (A developer is available if their `available_on` date is today or earlier.)

```ruby
# test/models/developer_test.rb

class DeveloperTest < ActiveSupport::TestCase
  test "available developers" do
    available = developers(:one)
    unavailable = developers(:two)

    available.update!(available_on: Date.yesterday)
    unavailable.update!(available_on: Date.tomorrow)

    assert_includes Developer.available, available
    refute_includes Developer.available, unavailable
  end
end
```

This might feel weird - it did to me at first. Aren’t two `UPDATE` queries slower than inserting a second fixture at boot time? Maybe! But the amount of time required to understand these tests is minimal.

**We keep all of the relevant information _in the test_, not the fixture.** The only field we care about is `available_on`, so we set it explicitly.

> If we are modifying a fixture then why not use `FactoryBot`? Because most of the time you won’t be touching the fixture. There are a lot of test cases where `developers(:one)` needs a developer, that’s it. Not special in any way. This is where fixtures shine - they are already loaded into the test database!

{% include newsletter/cta.liquid %}

## #3: Extract helpers for common customizations

For more complex tests you might need a handful of objects in the database. A common example is a query object that chains a couple of Active Record scopes. In my app we have a [`DeveloperQuery`](https://github.com/joemasilotti/railsdevs.com/blob/main/app/queries/developer_query.rb) that powers the search interface. As you can imagine, a _lot_ of different permutations of records are required.

> Side note, but in hindsight I think this model is what originally blew up the number of fixtures in the app. As we added new filters it required more permutations to query by.

Similar to #2, I want to **keep as much context in the test itself as possible**. Not buried in the fixture data. For this I create a few helpers to let me generate as many records as possible for each test.

Here’s a stripped down version of what my helper looks like. Nothing fancy here - a Ruby module gets us exactly what we need.

```ruby
module DevelopersHelper
  extend ActiveSupport::Concern

  included do
    def create_developer(options = {})
      Developer.create!(developer_attributes.merge(options))
    end

    private

    def developer_attributes
      {
        user: users(:empty),
        name: "Name",
        hero: "Hero",
        bio: "Bio"
      }
    end
  end
end
```

The “magic” is in merging the method parameters into the default attributes. **We can overwrite or customize the developer exactly as we want for each test.**

Note in this test we are setting the `available_on` explicitly, like we did before when updating the fixture. But this time we are creating new records.

```ruby
class DeveloperQueryTest < ActiveSupport::TestCase
  include DevelopersHelper

  test "sorting by availability excludes blank values" do
    present = create_developer(available_on: Date.yesterday)
    blank = create_developer(available_on: nil)

    records = DeveloperQuery.new(sort: :availability).records

    assert_includes records, present
    refute_includes records, blank
  end
end
```

This works well when you need to build up a few persisted objects in the database. But remember that you are still inserting records. So if there are chained dependencies or complex callbacks you risk taking a performance hit.

> “Hold on a second Joe, this looks a _lot_ like you’re recreating FactoryBot!” - You

I don’t deny that. If you’d rather use FactoryBot _and_ fixtures then go for it! But for my use case this single helper was enough - and one less gem to worry about.

## Guideline #4: Add additional fixtures only when dependencies are complex

Finally, my last guideline is to ignore the first guideline 😃.

The 1-2 existing fixtures don’t have anything special about them. That’s by design. But what if you need to create a record that has a few levels of relationships?

In my app a `Business` belongs to a `User` which belongs to a `Customer` which has many `Subscription` objects. (Phew!) I _really_ don’t want to create this manually every time I need to test something for a paying business.

Instead, I break guideline #1 and create a specialized fixture. The key here is that the others are named `:one` and `:two` respectively. Naming this new one something specific, `:paying_customer`, makes it immediately obvious that this is a special case.

I try to use this guidelines as sparingly as possible. Adding more fixtures will just get us back to the original problem! But I think having 1 _maybe_ 2 of these per model is a good tradeoff.

## Wrapping up

I felt the pain of having too many fixtures. To write a new test I had to dig through multiple files to figure out if there was the _perfect_ candidate for my test.

My refactor dropped the number of fixtures in the app from 89 to 43. That’s close to half - gone!

**These guidelines have made it easier to write new tests and modify existing ones.** And when a goal of the app is high test coverage, that means it’s easier to add new features.

---

If you’re interested, the product I’ve been talking about is [RailsDevs](https://railsdevs.com). It’s a reverse job board for Ruby on Rails developers. Instead of companies posting their job, you add your profile and they reach out to _you_. If you’re looking for your next gig (freelance or full-time) you should add your profile.

Have an opinion to share about this article? Mention or DM me on Twitter, I’d love to hear your thoughts! I’m [@joemasilotti](https://twitter.com/joemasilotti) and I tweet about Ruby on Rails, iOS, automated testing, and the intersection between them all.
