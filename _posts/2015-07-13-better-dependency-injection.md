---
layout: post
title:  "iOS: One Macro to Help Dependency Injection"
date:   2015-07-12
permalink: better-dependency-injection/
image: images/init-is-unavailable.png
description: "Better dependency injection on iOS with NS_UNAVAILABLE."
category: testing-objective-c
---

Learn how to improve the readability and predictability of your dependency injection in Objective-C. 

## Dependency Injection

Dependency Injection isn't new, but for some reason it's taken a while for the iOS community to really get behind it. In August 2014 a great introduction appeared on [objc.io](http://www.objc.io/issues/15-testing/dependency-injection/). Jon Reid discussed the pros and cons of three different approaches, Constructor Injection, Property Injection, and Method Injection. As always, each work better in different scenarios.

A quick overview of the three for those that missed it:

* Constructor Injection - pass in dependencies via an overloaded `-init` method
* Property Injection - lazy load dependencies but explicitly set them under test
* Method Injection - pass in the dependency to each method when needed

### Constructor Injection

If you have been exploring Constructor Injection you might be worried an object could be created without its dependencies. For example:

```objc
@interface Object : NSObject
- (instancetype)initWithDependency:(id<Protocol>)dependency;
@end
```

There's nothing stopping a consumer of this object to using the default `-init` method. This could lead to unexpected behavior due to Objective-C's "nice nil" policy. (That's where calling a method on `nil` doesn't throw an exception, unlike some other languages.)

What can we do about this? We could try raising an exception in the method that uses the dependency.

```objc
- (void)performOperationWithDependency {
    if (!self.dependency) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                reason:@"No dependency found!"
                               userInfo:nil] raise];
    }
    // do actual work...
}

```

Now this works quite well as the problem is explicit. It's obvious what the issue is and fixing it should be straightforward. But I think we can do one better; let's refactor.

What if we were able to inform the consumer earlier? What if the consumer knew there was something missing before the app even finished compiling?

### `NS_UNAVAILABLE`

Buried in the `NSObjCRuntime` header we find a seemingly useless macro, `NS_UNAVAILABLE`. We can attach this to the end of a method declaration to inform consumers that an object doesn't respond to that selector.

```objc
@interface Object : NSObject
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDependency:(id<Protocol>)dependency;
@end

```

Now you can't initialize this object without its dependency. The best part is that it occurs at build time and won't even show up in the autocomplete results.

![init is unavailable](/images/init-is-unavailable.png "-init is unavailable")

We can take this one step farther by adding a `__nonnull` annotation. Now we can guarantee that our object is set up with all its dependencies in order.

```objc
- (instancetype)initWithDependency:(id<Protocol> __nonnull)dependency;
```

If you are using Xcode 7 you can take advantage of the [new Nullability syntax for Objective-C](https://developer.apple.com/swift/blog/?id=25). The `nonnull` annotation must appear immediately after an open parenthesis. Thanks to [Apro in the comments](http://masilotti.com/better-dependency-injection/#comment-2180998497) for the suggestion!

```objc
- (instancetype)initWithDependency:(nonnull id<Protocol>)dependency;
```

Dependency Injection can be tricky. There's no need to add additional complexity with extra frameworks when we can use simple constructor injection. By taking advantage of a simple macro and annotation we can guarantee that every dependency is set up at compile time.

