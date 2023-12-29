---
title: Building NSURLs with NSURLQueryItems
date: 2014-10-26
description: Build and manipulate complex URLs with NSURLQueryItems. No more ugly string concatenation to append query items to URLs.
---

Building URLs in Objective-C is a fairly standard practice since most apps rely on some sort of backend server for data. Since the beginning of iOS development, SDK 2.0, Apple introduced [`NSURL`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/). These URLs can easily be created via an `NSString` with `-URLWithString:`. For example, if you wanted to ask the Twitter API for all of my tweets you could compose an NSURL like this:

```objc
NSString *urlString;
urlString = @"api.twitter.com/1.1/statuses/user_timeline.json";
urlString = [urlString stringByAppendingString:@"?screen_name=joemasilotti"];
NSURL *url = [NSURL URLWithString:urlString];
```

<p class="note">All example code is available at <a href="https://gist.github.com/joemasilotti/09fe1f247a3da1c782dd">this gist</a>.</p>

Nothing new or exciting going on there. But let's say you wanted to include retweets. According to the [API's documentation](https://dev.twitter.com/rest/reference/get/statuses/user_timeline) I can set the `include_rts` parameter to `true`. Let's try appending that on to our `NSString` object.

```objc
urlString = [urlString stringByAppendingString:@"&include_rts=true"];
url = [NSURL URLWithString:urlString];
```

Pretty straightforward, but what if we wanted to parameterize the user and count? We could build the `NSString` via `-stringWithFormat:` and pass in the options as a parameters.

```objc
NSString *screenName = @"joemasilotti";
NSString *includeRTs = @"true";

urlString = @"api.twitter.com/1.1/statuses/user_timeline.json";
urlString = [urlString stringByAppendingFormat:@"?screen_name=%@", screenName];
urlString = [urlString stringByAppendingFormat:@"&include_rts=%@", includeRTs];

url = [NSURL URLWithString:urlString];
```

As expected this can quickly become unwieldy. Let's try building this via `NSURLComponents` instead.

[`NSURLComponents`](https://developer.apple.com/library/IOs/documentation/Foundation/Reference/NSURLComponents_class/index.html) provides structured methods to create and query `NSURL`s such as `-scheme`, `-host`, `-path`,  and`-query`. Let's build the same `NSURL` with `NSURLComponents`.

```objc
NSURLComponents *components = [[NSURLComponents alloc] init];
components.scheme = @"http";
components.host = @"www.api.twitter.com";
components.path = @"/1.1/statuses/user_timeline.json";
components.query = @"screen_name=joemasilotti&include_rts=true";
url = components.URL;
```

Note: More `NSURLComponents` explanation, examples, and magic can be found on Mattt Thompson's [NSHipster blog](http://nshipster.com/nsurl/).

Nice! But was this really easier than just parsing out our full URL from a string? Probably not, but let's try and change the query. A few approaches to this:

1. Build the query via an `NSDictionary`, iterate through the objects and insert the *&* and *?* in the correct spot(s).
2. Use `NSString -stringByReplacingOccurrencesOfString:withString:` to replace "placeholder" text throughout a standard query.
3. Manually append each query item and keep track of the correct locations for *&* and *?*s.

All three of these would work fine and probably wouldn't even be difficult to implement. However, each comes with its own set of headaches and pain points. For example, what if you wanted multiple values set to the same key for the first solution? `NSDictionary` would not allow that. The second solution ties you to a very specific URL query and adding new items would be difficult.

The last is probably most common as it is most straightforward. The largest issue is that you will have to always maintain a state. If you wanted to have a factory to create these for you it would need to be in charge of parsing out *exisisting* parameters just to build new ones. Not good.

Let's try something else.

Instead of asking for `-query`, let's try `-queryItems`.

```objc
NSLog(@"%@", components.queryItems);
/*
(
  "<NSURLQueryItem 0x7fbdbb4281b0> {name = screen_name, value = joemasilotti}",
  "<NSURLQueryItem 0x7fbdbb428250> {name = include_rts, value = true}"
)
*/
```

Ah, the newly added `NSURLQueryItem`! This was added in iOS 8 and OS X 10.10 and from the docs:

> An NSURLQueryItem object represents a single name/value pair for an item in the query portion of a URL. You use query items with the queryItems property of an NSURLComponents object.

Query items are much awaited objects to create and modify queries in our `NSURL`. We can easy initialize them with the designated initializer `+initWithName:Value`.  Once we generate a few we can set the `-queryItems` property of our `NSURL` as an `NSArray`. Doing so makes our query much more pragmatic.

```objc
NSURLQueryItem *screenNameItem, *includeRTsItem;
screenNameItem = [NSURLQueryItem queryItemWithName:@"screen_name"
                                             value:@"joemasilotti"];
includeRTsItem = [NSURLQueryItem queryItemWithName:@"include_rts"
                                             value:@"true"];
components.queryItems = @[ screenNameItem, includeRTsItem ];
url = components.URL;
```

What's really great about these guys is all of the formatting (question mark and ampersand) is taken care of automatically. That means you can modify the items at will and never have to worry about proper string formatting for inserting the delimeters.

There are also a bunch of [other assumptions being made](https://developer.apple.com/library/IOs/documentation/Foundation/Reference/NSURLComponents_class/index.html#//apple_ref/occ/instp/NSURLComponents/queryItems) to conform to correct URL structure:

>To ensure you can compose and decompose URL queries even with empty components, the NSURLComponents class has the following behavior for cases where no name or value is present:
>
>If a name-value pair has nothing before its equals sign, the name property of the corresponding query item is a zero-length string.
>
>If a name-value pair has nothing after its equals sign, the value property of the corresponding query item is a zero-length string.
>
>If a name-value pair has no equals sign, the value property of the corresponding query item is nil.
>
>If a name-value pair is empty (that is, the query string starts with &, ends with &, or contains &&), the corresponding query item has a zero-length name and nil value.

Hopping over to the other side of the fence, you can query these items just as easily. If we wanted to assert a certain query item was set (ahem, testing, ahem) we can do without minimal effort.

```objc
for (NSURLQueryItem *item in components.queryItems) {
    if ([item.name isEqualToString:@"screen_name"]) {
        if ([item.value isEqualToString:@"joemasilotti"]) {
            return YES;
        }
    }
    return NO;
}
```

One better, we could even check for the explicit name value pair.

```objc
NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:@"screen_name"
                                                   value:@"joemasilotti"];
[components.queryItems containsObject:item] should be_truthy;
```
