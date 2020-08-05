---
layout: post
title: Testing URLSession with Swift
permalink: testing-nsurlsession/
summary: "Three posts covering testing URLSession with Swift. Learn how to mock class you don't own, flatten asynchronous tests, and stub data for UI Testing."
---

A series of blog post covering how to test `URLSession` with Swift. Broken down into three parts, each discussing different aspects of the testing process.

First, learn how to verify that you send the right parameters to the session. Next, speed up your test suite by making all `URLSession` API calls synchronous. Finally, tie it all together by stubbing JSON responses when running UI Tests.

## 1. [Mocking Classes You Don't Own]({% post_url 2016-01-11-testing-nsurlsession-1 %})

> Not owning a class doesn't mean you can't mock it! Learn how to unit test `URLSession` with Swift and protocol-oriented programming.

My go-to approach when unit-testing Swift is protocol-oriented programming. As requested by you, let's see a real-world example. What better way to show some code than with the networking stack, something every iOS developer has dealt with!

## 2. [Flattening Asynchronous Tests]({% post_url 2016-02-01-testing-nsurlsession-async %})

> Shave time off your test suite by flattening asynchronous tests. Learn how to mock more of `URLSession` to test response data, network errors, and status codes.

You've sent your fully tested HTTP request off into the wild. Now, what happens when it returns? How do you test for response data? What about network errors? Server errors? Let's take a look at how to test these network responses, and more, in this second post on testing `URLSession`.

## 3. [Stubbing Data for UI Testing]({% post_url 2016-03-04-ui-testing-stubbed-network-data %})

> Learn how to stub network data when running UI Tests with the magic of some “secret” XCTest APIs.

We've all been there. We get super excited to try out UI Testing and start to use it for all the app's flows. And then one of the tests requires the user to be logged in.

What do we do? Have a "test user" whose password never changes? Create a mock server? Forget the test entirely? There's got to be something better!

With just a little bit of code, we can stub out network data when running our UI Tests. How? With the magic of some "secret" XCTest APIs.

<hr />
