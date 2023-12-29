---
title: Capture completion blocks with Cedar BDD
date: 2015-07-20
description: Flatten out your asynchronous tests with and_do_block().
---

[Cedar](http://github.com/pivotal/cedar) is a [behavior-driven development](http://guide.agilealliance.org/guide/bdd.html) framework for testing Objective-C. By following [Rspec-like syntax](http://www.rubydoc.info/gems/rspec-expectations/frames#Basic_usage), you can build up a series of interactions with your object under test.

![Cedar BDD](/assets/images/completion-blocks-with-cedar/cedar.png){:standalone .unstyled}

> Read more about how Cedar came to be in my [post on UI Testing]({% post_url 2015-06-29-ui-testing-xcode-7 %}).

Testing asynchronous code can be difficult in Cedar. Because the test suite is injected into your app's bundle, it ticks with the same run loop. This means waiting around for events to occur can be difficult at best and cause test pollution at worst.

But all hope is not lost. A small gem was introduced in [Cedar 0.9.7](https://github.com/pivotal/cedar/releases/tag/v0.9.7) that can help you easily navigate the world of completion blocks.

## Asynchronous blocks

Let's say your app fetches the latest movies from [Rotten Tomatoes](http://developer.rottentomatoes.com). The `MovieController` asks your `MovieService` for the most recent showtimes. Since a network request is involved, we need this call to be asynchronous. To accomplish this we can pass in a block parameter to be called when the movies are fetched.

```objc
typedef void (^MovieCompletion)(NSArray *movies, NSError *error);

@interface MovieService : NSObject
- (void)getMoviesWithCompletion:(MovieCompletion)completion;
@end
```

When testing the `MovieController`, how can we test the interaction with its service? We don't want to make network requests under test so let's use a double.

> **Q: What's the difference between a *double*, *stub*, *spy*, *mock*, and *fake*?**
>
> A: [objc.io's article on testing](http://www.objc.io/issues/15-testing/mocking-stubbing/#when-would-you-want-to-use-some-sort-of-mock-object) has a great overview from [Mike Lazer-Walker](http://lazerwalker.com).

To accomplish this we can use [dependency injection](http://www.objc.io/issues/15-testing/dependency-injection/) to inject a service into the controller.

```objc
@class MovieService;

@interface MovieController : UIViewController
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithService:(MovieService *)service;
@end
```

> If you haven't used `NS_UNAVAILABLE` it's a great way to [improve the readability and predictability of your DI]({% post_url 2015-07-13-better-dependency-injection %}).

Now in our test let's ensure the controller fetches the movies when the view loads.

```objc
SPEC_BEGIN(MovieControllerSpec)

describe(@"MovieController", ^{
    __block MovieController *subject;
    __block MovieService *service;

    beforeEach(^{
        service = fake_for([MovieService class]);
        service stub_method(@selector(getMoviesWithCompletion:));

        subject = [[MovieController alloc] initWithService:service];
    });

    describe(@"when the view loads", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should fetch the movies", ^{
            service should have_received(@selector(getMoviesWithCompletion:));
        });
    });
});

SPEC_END
```

When the results are returned we need to validate that the data is populated correctly. But how can we capture the completion block to call later? Enter `and_do_block()`.

### and\_do\_block()

By stubbing out the service with `and_do_block()`, we essentially swap the implementation of a method. For example:

```objc
describe(@"and_do_block()", ^{
    __block NSObject *object;

    beforeEach(^{
        object = fake_for([NSObject class]);

        object stub_method(@selector(description)).and_do_block(^(){
            return @"Hello, stub!";
        });
    });

    it(@"should return the stubbed string", ^{
        [object description] should equal(@"Hello, stub!");
    });
});
```

What we are doing is saying "hey fake, when this method is called, do this thing." If the method returns something, then we can easily mimic it by calling `return` in our fake implementation. Things get really interesting when the method takes a parameter.

```objc
describe(@"and_do_block() with parameters", ^{
    __block NSArray *array;

    beforeEach(^{
        array = fake_for([NSArray class]);

        array stub_method(@selector(objectAtIndex:))
        .and_do_block(^(NSUInteger index) {
            return [NSString stringWithFormat:@"%@", @(index)];
        });
    });

    it(@"should return the passed in index", ^{
        [array objectAtIndex:6] should equal(@"6");
    });
});
```

Here we capture the passed in parameter, the index, and perform some formatting logic on it. This technique can easily be expanded to capture multiple arguments of different types. Just make sure your block parameters match your method signature.

## Capture the completion handler

Back to our `MovieController` test, let's use `and_do_block()` to capture our block. If we update the `beforeEach` with the following, we now have a reference to our completion block.

```objc
__block MovieCompletion completion;

beforeEach(^{
    completion = nil;

    service stub_method(@selector(getMoviesWithCompletion:))
    .and_do_block(^(MovieCompletion localCompletion) {
        completion = localCompletion;
    });

    subject.view should_not be_nil;
});
```

Beautiful! By having a strongly-typed completion block, `MovieCompletion`, we keep this code easy to read by treating the block like any other parameter argument.

Now that we have a reference to the completion handler we can call it with different parameters. For example, what happens when the service returns movies? What happens when it encounters an error?

```objc
context(@"when the service returns movies", ^{
    beforeEach(^{
        Movie *movie1 = [[Movie alloc] initWithName:@"Movie One"];
        Movie *movie2 = [[Movie alloc] initWithName:@"Movie Two"];
        completion(@[ movie1, movie2 ], nil);
    });

    it(@"should populate the table", ^{
        [subject.tableView.visibleCells valueForKeyPath:@"textLabel.text"]
        should equal(@[ @"Movie One", @"Movie Two" ]);
    });
});

context(@"when the service returns an error", ^{
    beforeEach(^{
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    });

    it(@"should inform the user something went wrong", ^{
        subject.view.errorLabel.text should_not be_nil;
    });
});
```

## Code quality

This approach to testing asynchronous Objective-C keeps our test suite synchronous, [which is a good thing](http://lowlevelbits.org/getting-rid-of-asynchronous-tests/). We don't have to mess with the run loop and there's no need to build up stacks of mock HTTP responses.

To create more readable tests we `typedef` our completion handlers. That, combined with dependency injection, allows us to inject fakes or mocks to our controller when under test. Combining these we have a more readable, reliable, and faster test suite.

