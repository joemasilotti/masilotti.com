---
title: NSDate Manipulation in iOS
date: 2015-02-02
description: Create and modify dates by taking advantage of iOS 8's NSCalendar APIs.
---

Apple quietly introduced a whole new suite of public API methods to `NSCalendar` in iOS 8 titled "Calendrical Calculations". For some reason they seemed to have forgotten to include them in the public documentation on their developer site. Fortunately, digging in to the header file in Xcode reveals lots of descriptive comments about how to use these powerful new ways of interacting with `NSDate` objects.

In iOS 7 all `NSDate` manipulation required working with `NSDateComponents` directly. While there is nothing inherently wrong with this class it is terribly verbose. Most of the manipulations require converting an `NSDate` to its components, fiddling with one or more of the values, then creating a new date by hand. I’ll compare a few common operations and you can decide which are more legible, terse, and easy to understand.

Note that these new APIs don’t add any new functionality to the framework. Think of them as shortcuts and more readable ways of doing standard date operations.

> Follow along with the code [via this gist](https://gist.github.com/joemasilotti/8d80db6b4f453894bbac).

## Create an `NSDate` Three Hours in the Future

To create an `NSDate` object three hours from now we only have one API call (after getting an `NSCalendar` instance).

```objc
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *threeHoursFromNow;
threeHoursFromNow = [calendar dateByAddingUnit:NSCalendarUnitHour
                                        value:3
                                       toDate:[NSDate date]
                                      options:kNilOptions];
```

This method will account for overflow as expected. Try passing in 24 for the `value` parameter and watch the date’s day increase. Following this same approach you can easily manipulate other units by setting the first parameter to your desired granularity.

Comparing this to the old approach of fishing out `NSDateComponents`, then setting the specific property, then creating an `NSDate` from said components you can quickly see how powerful and readable the new API is. Here is a rundown of how we could have done it "the old way". Note that all of the `NSCalendarUnit`s are required to ensure the newly created date has all of the same properties from the original one.

```objc
NSCalendar *calendar = [NSCalendar currentCalendar];
NSCalendarUnit calendarUnits = NSCalendarUnitTimeZone | NSCalendarUnitYear
| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour
| NSCalendarUnitMinute | NSCalendarUnitSecond;
NSDateComponents *components = [calendar components:calendarUnits
                                           fromDate:[NSDate date]];
components.hour += 3;
NSDate *threeHoursFromNow = [calendar dateFromComponents:components];
```

## Getting the Next Occurrence of a Time

Let’s say you need to compute when the next occurrence of a time happens. For example, you could be trying to schedule a local notification to fire the *next* time it’s 9:30am. (Remember, scheduling a `UILocalNotification` in the past makes it fire *immediately*!) Again, using the new API we can achieve this in one call.

```objc
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *nextNineThirty = [calendar nextDateAfterDate:[NSDate date]
                                        matchingHour:9
                                              minute:30
                                              second:0
                                             options:NSCalendarMatchNextTime];
```

Using the old APIs would require us to take a few more steps. First we create a new date from today’s date and set the relevant components. If the new date's hour and minute are "more than" todays’s then return the new date, otherwise increment the day component.

Note the annoying and cryptic `if` statement doing the actual calculation. You can easily imagine how this would snowball if we cared about more components.

```objc
NSCalendar *calendar = [NSCalendar currentCalendar];
NSCalendarUnit calendarUnits = NSCalendarUnitTimeZone | NSCalendarUnitYear
| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour
| NSCalendarUnitMinute | NSCalendarUnitSecond;
NSDateComponents *components = [calendar components:calendarUnits
                                           fromDate:date];

if (components.hour > hour ||
    (components.hour == hour && components.minute > minute)) {
    components.day++;
}
components.hour = hour;
components.minute = minute;

NSDate *nextDate = [calendar dateFromComponents:components];
```

## Comparing Dates (with Granularity)

Gone are the days of breaking down dates into seconds then doing math to compute comparisons. Two new methods introduced help us compare `NSDate`s with unit granularity. This can simplify a lot of existing code where you would need to know if a date is *sort of* bigger or smaller than the other. For example, comparing if a *day* is after another day (disregarding time) you could specify the `NSCalendarUnitDay` granularity.

```objc
NSDate *today = [NSDate date];

NSDate *laterToday = [calendar dateByAddingUnit:NSCalendarUnitMinute
                                          value:20
                                         toDate:today
                                        options:kNilOptions];
NSComparisonResult result1 = [calendar compareDate:today
                                            toDate:laterToday
                                 toUnitGranularity:NSCalendarUnitDay];
// result1 = NSOrderedSame

NSDate *tomorrow = [calendar dateByAddingUnit:NSCalendarUnitHour
                                        value:24
                                       toDate:today
                                      options:kNilOptions];
NSComparisonResult result2 = [calendar compareDate:today
                                            toDate:tomorrow
                                 toUnitGranularity:NSCalendarUnitDay];
// result2 = NSOrderedAscending
```

As mentioned above, the second date manipulation handles the overflow of the hours and increments the day.

One approach to a solution to this problem using the old APIs is to generate new `NSDate`s with only the relevant components. You can then compare the two as the other attributes will be striped. Unfortunately this is quite cryptic. Coming back to this code in a month or two you might not remember why you only grabbed three components when everywhere else in the app you use more.

```objc
NSCalendar *calendar = [NSCalendar currentCalendar];
NSCalendarUnit calendarUnits;
calendarUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;

NSDateComponents *components1 = [calendar components:calendarUnits
                                            fromDate:date1];
NSDateComponents *components2 = [calendar components:calendarUnits
                                            fromDate:date2];

NSDate *lessGranularDate1 = [calendar dateFromComponents:components1];
NSDate *lessGranularDate2 = [calendar dateFromComponents:components2];

NSComparisonResult result = [lessGranularDate1 compare:lessGranularDate2];
```

## Is This Date Today? Tomorrow? Yesterday?

Finally, let’s look at a few new conveinence methods that build on the previous method. If you have very specific requirements for figuring out if a particular `NSDate` is today, tomorrow, or yesterday you are in luck.

```objc
NSDate *today = [NSDate date];
[calendar isDateInToday:today];
[calendar isDateInTomorrow:today];
[calendar isDateInYesterday:today];
```

iOS 7 compatible code can follow the same basic approach as the `-isDateInToday:` method. Essentially, only grab components that are necessary then compare.

```objc
NSCalendar *calendar = [NSCalendar currentCalendar];
NSCalendarUnit calendarUnits;
calendarUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;

NSDateComponents *components = [calendar components:calendarUnits
                                           fromDate:date];
NSDateComponents *todayComponents = [calendar components:calendarUnits
                                                fromDate:[NSDate date]];

NSDate *lessGranularDate1 = [calendar dateFromComponents:components];
NSDate *lessGranularToday = [calendar dateFromComponents:todayComponents];

BOOL isInToday = [lessGranularDate1 isEqualToDate:lessGranularToday];
```

## Benefits of Highly Abstracted APIs

The new high level `NSCalendar` API gives developers more concise, terse, and legible ways of manipulating dates as we no longer have to muck around with crufty `NSDateComponents` and `NSCalendarUnit` bit masks. There is less moving parts and more direct manipulation. This makes code easier to read and understand leading to faster development time and fewer bugs. It makes you wonder why Apple didn’t include these in earlier versions of iOS.

From my count there are 32 new API methods added to `NSCalendar` in iOS 8 and I didn’t even touch upon validating dates, iterating over a series of dates, or matching dates by component. If you’re interested in learning more take a peek at the header file and add a comment with your findings below.
