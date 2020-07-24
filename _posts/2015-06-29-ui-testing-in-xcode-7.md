---
layout: post
title:  "UI Testing in Xcode 7"
date:   2015-06-29
permalink: ui-testing-xcode-7/
image: images/xcode-testing.png
description: "How to navigate around an undocumented but powerful framework in iOS 9."
category: ui-testing
---

Apple finally decided to double down on user interface testing at WWDC this year. Let's take a deep dive into the API and see what we find.

![Xcode Testing](/images/xcode-testing.png "Xcode Testing")

## Background

I’ve been testing on iOS for a few years now. Before starting at [BeerMenus](https://www.beermenus.com), I spent two years at [Pivotal Labs](http://pivotallabs.com). Pivots, as we like to be called, take testing seriously. Being a [test-driven development](https://en.wikipedia.org/wiki/Test-driven_development) firm (or TDD firm), Pivots take the time to test every nook and cranny of an app or a website. While specific code coverage numbers aren't a priority, they easily comprise 95% of most, if not all, projects.

### Cedar

The only way to test an iOS app back with Xcode 4 was OCUnit, which left much to be desired. Pivots used their expertise in [behavior-driven development](https://en.wikipedia.org/wiki/Behavior-driven_development) frameworks and set out to create their own - and [Cedar](https://github.com/pivotal/cedar) was born.

Cedar is an excellent framework for creating BDD-style tests with full support for matchers and fakes. While Xcode 7 is not yet fully supported, Pivotal is [tracking their work on a branch](https://github.com/pivotal/cedar/tree/Xcode7) and is expected to release something soon. I’ve been using Cedar to test every iOS app I’ve worked on since drinking the TDD Kool Aid. I’ve even started to use it to feature test controllers, but that is a topic for another time.

Using Cedar alone doesn’t give me the end-to-end coverage I have grown to appreciate when working in Ruby on Rails. I can’t reliably spin up the app and tap through a few screens. Understandably so, Cedar wasn’t made for that. To fill the gap a number of players have created their own third-party feature testing frameworks. 

### Third Party Experiments

[Frank](https://github.com/TestingWithFrank/Frank), [KIF](https://github.com/kif-framework/KIF), [Subliminal](https://github.com/inkling/Subliminal), and Apple's [UIAutomation](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/UsingtheAutomationInstrument/UsingtheAutomationInstrument.html), I’ve tried them all. You can read more about why they all leave a lot to be desired in my [breakdown of feature testing frameworks](https://github.com/joemasilotti/ios-feature-testing). It’s not the developers' fault, it’s Apple’s limiting openness when it comes to testing. This makes each of these frameworks nothing more than a series of monkey patches on top of already broken tools.

Without getting into too much detail:

* Frank has long been abandoned
* KIF breaks with every major iOS revision
* Subliminal can’t be run reliably from the command line
* UIAutomation is written in JavaScript and clunky

I worked on six separate apps during my time at Pivotal and tried a different framework for each one. I’ve even [contributed to both KIF](https://github.com/kif-framework/KIF/commits?author=joemasilotti) and [Frank](https://github.com/TestingWithFrank/Frank/commits?author=joemasilotti) because I *wanted* these frameworks to succeed. Unfortunately it just isn’t possible without support from Apple.

## WWDC 2015

![WWDC](/images/wwdc.png)

Exciting news came this year at WWDC: the [introduction of User Interface Testing](https://developer.apple.com/videos/wwdc/2015/?id=102) during the Platforms State of the Union.

> Xcode 7 introduces user interface testing, ensuring that changes you make in code don’t show up as unwanted changes to your users.

Wil Turner and Brooke Callahan present the new framework in session 406, [UI Testing in Xcode](https://developer.apple.com/videos/wwdc/2015/?id=406). If you haven't watched it yet, I recommend you take a look. They demo a simple task manager application and highlight some of the APIs and features included with the tools.

![WWDC Demo](/images/wwdc-demo.png "WWDC Demo")

UI Testing's big claim to fame is "Recording." After you have a working application, you tap a big red circle and start tapping around in your app. As you interact with your app, code is automatically generated to reproduce your flow. In theory, you are then able to run the newly created test and watch as your app repeats your actions.

## UI Testing in Practice

Claims and demos are one thing, but how does the framework work in the real world?

### Documentation

![XCTest documentation in Dash](/images/documentation.png "XCTest documentation in Dash")

One of the first things you might notice about the new framework is the lack of documentation. Neither iOS 9 nor Xcode 7 include any official docs on UI Testing. Luckily, most of the new `XCU*` classes have well commented header files. By using [appledoc](https://github.com/tomaz/appledoc), I was able to pull these header files into an Xcode and [Dash](https://geo.itunes.apple.com/us/app/dash-api-docs-snippets/id458034879?mt=12&uo=6&at=11lGGj) compatible docset. Just clone [the repository](https://github.com/joemasilotti/XCTest-Documentation) and open up the file; your default documentation browser will add the new APIs. ~~You can also view the documentation online~~. **Edit**: Apple released [official documentation](https://developer.apple.com/documentation/xctest/user_interface_tests).

UI Testing lives in the `XCTest` framework and adds four new classes, one new protocol, and three new constants.

#### Launching the App - `XCUIApplication`

This is the main hook for launching your testable application. You create a new one, `XCUIApplication()` and then call `launch()` on it. If you add a new UI Test target to your app you will see an example in the template. Before launching you can set specific arguments or environment variables by setting the `-launchArguments` or `-launchEnvironment` properties, respectively. This creates a nice layout for telling your HTTP client, for example, to hit a mock server when under test.

````swift
let app = XCUIApplication()
app.launchArguments = [ "USE_MOCK_SERVER" ]
app.launch()
````

You can also `-terminate` your app, but I haven't found a use for that just yet.

#### Accessing the Device - `XCUIDevice`

You can create a new instance of this object with `+sharedDevice`. The only publicly accessible property is `-orientation` which returns the usual `UIDeviceOrientation` enum. Even though this is a read/write property, setting it does not update the interface of the simulator. I'm not sure if this is a bug in the beta I was using though.

#### Querying for Elements - `XCUIElementQuery`

This is the class your UI tests will use the most. You use it to build queries to locate your elements. Remember `app.tableViews[0].cells[0]` from UIAutomation? Well, this looks almost identical and is used in a very similar fashion. 

````swift
app.tables.element.cells.elementBoundByIndex(4).tap()
````

Each call down the stack returns another query object that can be chained together. This gives you precise control to target specific views in your app without much overhead. By referencing `-element` you are essentially saying, "I know there is only one of these, I want that one." You can also reference objects in the arrays by accessibility label.  

````swift
app.tables.element.cells["Call Mom"].buttons["More"].tap()
````

These convenience methods work by calling `-elementMatchingType:identifier:` with `XCUIElementTypeAny` and the string you passed in. Check out `XCUIElementType` for all the options if you want finer grain control.

#### Interacting with Elements - `XCUIElement`

> Elements are objects encapsulating the information needed to dynamically locate a user interface element in an application. Elements are described in terms of queries. **When an event API is called, the element will be resolved.** If zero or multiple matches are found, an error will be raised.

This means that you create an `XCUIElementQuery`, which give you *references* to elements. Not until you actually try to interact with them does the framework actually look through the app's hierarchy to find it. This has huge advantages for keeping your tests [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) - you can keep a reference to a query and reuse it at different points of the test. The element will only be found during the interaction, saving you the effort to have to drill down again.

Interactions are named appropriately and do what you would expect. For example, in iOS you can use `-tap`, `-pressForDuration:`, `-swipeUp`, and `-twoFingerTap`. If you are testing an OS X app you can use the `-click*` counterparts. You can even use `+performWithKeyModifiers:block:` to simulate holding down the `⌘` key.

### Assertions

What would a testing framework be without assertions? Since UI testing is just an extension of XCTest, all of the existing assertions already work. This means you have access to the macros like `XCTAssert()`, `XCTAssertEquals()`, and `XCTAssertNotNil()`. 

#### Checking If an Element Exists

One might be tempted to use a not-nill assertion on an element to see if it exists or not.

````swift
XCTAssertNotNil(app.buttons["Submit"])
````

However, `-elementMatchingType:identifier:` *always* returns an object. It is not until that is resolved that it decides if an element actually matches the query. This means this test will *always* pass. 

Instead, call `-exists` on the element and wrap that in an assertion.

````swift
XCTAssert(app.buttons["Submit"].exists)
````

Another way to approach assertions is to not use any at all. While running the tests if a resolved query doesn't match an element the test will automatically fail. Make sure to turn off `[XCTestCase -continueAfterFailure]` in your `-setUp` method.

### Debugging

A technique I often use when debugging is to set a breakpoint and print out some objects in the console. (Mind blowing, I know.) Setting a breakpoint in your test code will get hit and the debugger will attach without issue. ~~However, you *cannot* attach the debugger to your app code. Logged statements will appear as expected in the console so take advantage of that.~~

> **Update** *23 Jul 2015*: Xcode 7 Beta 4 fixes this issue. You can now attach breakpoints in both tests and the app code. Both will be hit during excecution of your tests.

![Table with five cells](/images/table-with-five-cells.png "Table with five cells")

When printing an `XCUIElementQuery` from the console, you are presented with a lot of noise. Imagine a table with five cells labeled "One" through "Five". To target the cell labeled "Three" you could print something like this (some keys omitted for clarity):

````swift
(lldb) po app.tables.element.cells[@"Three"]
Query chain:
 →Find: Target Application
  ↪︎Find: Descendants matching type Table
    Input: {
      Application:{ {0.0, 0.0}, {375.0, 667.0} }, label: "Demo"
    }
    Output: {
      Table: { {0.0, 0.0}, {375.0, 667.0} }
    }
    ↪︎Find: Descendants matching type Cell
      Input: {
        Table: { {0.0, 0.0}, {375.0, 667.0} }
      }
      Output: {
        Cell: { {0.0, 64.0}, {375.0, 44.0} }, label: "One"
        Cell: { {0.0, 108.0}, {375.0, 44.0} }, label: "Two"
        Cell: { {0.0, 152.0}, {375.0, 44.0} }, label: "Three"
        Cell: { {0.0, 196.0}, {375.0, 44.0} }, label: "Four"
        Cell: { {0.0, 240.0}, {375.0, 44.0} }, label: "Five"
      }
      ↪︎Find: Elements matching predicate ""Three" IN identifiers"
        Input: {
          Cell: { {0.0, 64.0}, {375.0, 44.0} }, label: "One"
          Cell: { {0.0, 108.0}, {375.0, 44.0} }, label: "Two"
          Cell: { {0.0, 152.0}, {375.0, 44.0} }, label: "Three"
          Cell: { {0.0, 196.0}, {375.0, 44.0} }, label: "Four"
          Cell: { {0.0, 240.0}, {375.0, 44.0} }, label: "Five"
        }
        Output: {
          Cell: { {0.0, 152.0}, {375.0, 44.0} }, label: "Three"
        }
````

This is huge insight into how the framework is locating your elements. Notice `-tables` in the first input/output loop returns the table that fills this iPhone 6 simulator. Then drilling down to `-cells` returned all of the cells. Finally, the text query only returned the one element at the end. **If you don't see the "Output" key at the end of a query it means the framework did not find your element.**

## Is It Ready?

> **Update** *25 Jul 2015*: Read on for Beta 4 updates. Beta 2 is being kept for historical reasons.

### Beta 2

As of Xcode 7 Beta 2, UI Testing shows promise. It's reliable, the querying engine is powerful, and it's more future-proof than any third-party library can realistically be.

However, it does have some quirks. There is currently no way of *natively* waiting for elements to appear or disappear. This means you can't wait for network activity to finish before continuing. I've tried everything from asynchronous testing to ticking the run loop to good old `sleep()`. ~~Unfortunately as soon as you mess with any app timing, Xcode starts to choke and the tests will crash and fail.~~

> **Update** *30 Jun 2015*: Thanks to [Lammert in the comments]({{ page.url }}/#comment-2108346090), you can hack your way around this. By ticking the run loop you can effectively "wait" for a set period of time.
>
> You can easily extend this to wait until an element is gone. One catch is that in Xcode 7 Beta 2 you have to wait for one second when the app launches before calling `-exists`.
>
> I've added this and some other helpful methods to the [JAMTestHelper Cocoapod](https://cocoapods.org/pods/JAMTestHelper). The pod also includes `waitForElementToExist()` and `waitForElementToNotExist()`.

````objc
- (void)waitForSpinner {
    while (self.app.buttons[@"HUD"].exists) {
        NSDate *smallDelay = [NSDate dateWithTimeIntervalSinceNow:0.1f];
        [[NSRunLoop mainRunLoop] runUntilDate:smallDelay];
    }
}
````

### Beta 4

Now things get interesting. Apple engineering manager Joar Wingfors ([@joar\_at\_work](http://twitter.com/joar_at_work)) recently pointed out an important change in the latest beta. UI Testing can now natively wait for elements and animations. `/giphy awesome`

#### How to Wait for Elements with UI Testing

Imagine we are writing a UI test around loading some content off the web. Since it won't be present immediately we will need to set up some expectations for the event. This isn't new, it was introduced in Xcode 6, but **now it works with UI Testing**.

````swift
let label = app.staticTexts["Hello, world!"]
let exists = NSPredicate(format: "exists == true")

expectationForPredicate(exists, evaluatedWithObject: label, handler: nil)
waitForExpectationsWithTimeout(5, handler: nil)
````

Here we create a query to wait for a label with text "Hello, world!" to appear. The predicate matches when the element exists (`element.exists == true`).

We then pass the predicate in and evaluate it on the label. Finally, we kick off the waiting game with `-waitForExpectationsWithTimeout:handler:`. Simple as that!

If five seconds pass before the expectation is met then the test will fail. You can also pass a handler block in that gets called when the expectation fails or times out.

> **Pro Tip**: Learn how to [extract this into a test helper]({% post_url 2015-09-21-xctest-helpers %}).

### Beta 5

A few minor changes were added with Xcode 7 Beta 5. The most interesting additions add support for pinching and zooming. Under the hood they are taking advantage of the new `XCUICoordinate` class. Lucky for us this is abstracted away into simple, percentage-based parameters.

#### Pinching and Zooming

You can use these new methods to manipulate maps. For example, to zoom in on the center of a `MKMapView`:

````swift
app.maps.element.pinchWithScale(1.5, velocity: 1)
````

According to the [documentation for UI Testing](/xctest-documentation/Classes/XCUIElement.html#//api/name/pinchWithScale:velocity:), the `scale` parameter will determine a zoom out or zoom in gesture. 

> Use a scale between 0 and 1 to “pinch close” or zoom out and a scale greater than 1 to “pinch open” or zoom in.

Also note that the `velocity` parameter has a restrictions as well. If you are zooming out (a scale between 0 and 1) you the velocity must be less than zero.

By using a combination of pinches and swipes, you can narrow in on a specific address on your map.

### Beta 6

#### Interacting with Pickers

With the Beta 6 release last night we were given yet another tool, interaction with pickers. The release notes identify `UIDatePicker` and `UIPickerView` as "complex controls". What's awesome about this is how many times it was requested in the developer forums. I've also seen a handful of Radars opened asking for the same thing. 

First, let's get a picker on the screen. Then populate it with ten items, one for each iPhone model released so far. I've added this [boilerplate to a GitHub project](https://github.com/joemasilotti/UIPickerViewTester) if you don't want to write the code yourself.

![!UIPickerView Example](/images/picker-example.png "UIPickerViewExample")

With the addition of `-adjustToPickerWheelValue:` on `XCUIElement`, selecting an item is pretty trivial. Just make sure you call it on an actual picker or the framework will raise an exception.

````swift
app.pickerWheels.element.adjustToPickerWheelValue("iPhone 3GS")
XCTAssert(app.staticTexts["iPhone 3GS"].exists)
````

Note that this only works with a single picker on the screen. If you have more than one you will have to specify the picker explicitly where I called `-element`.

> [Relevant documentation on interacting with pickers](/xctest-documentation/Classes/XCUIElement.html#//api/name/adjustToPickerWheelValue:) 

#### Hardware Buttons

If your app adds custom behavior to the volume controls than this addition is for you. After referencing the shared device singleton, we can press different hardware buttons.

````swift
XCUIDevice.sharedDevice().pressButton(XCUIDeviceButton.VolumeUp)
````

Note that `VolumeUp` and `VolumeDown` are not available in the simulator and should only be tested on a real device. The documentation for `XCUIDeviceButton` recommends surrounding this code in the `TARGET_OS_SIMULATOR` macro.

> [Relevant documentation on tapping hardware buttons](/xctest-documentation/Constants/XCUIDeviceButton.html)

#### Recording

Attempting to record particular events doesn't register at all. For example, any interaction with `WKWebView` must be written manually. And good luck interacting with system alerts when asked for location authorization. Beta 6 also still hasn't enabled `UIPickerView` recording support. I'm hoping that these improve with the next beta release and are fixed by the GM.

Overall I think that everyone should at least try out UI Testing on their own project. It offers new ways of validating your application and a second level of test assertions which any app in the App Store can benefit from. I'm excited to farther integrate it into the projects I work on everyday and look forward to seeing how the rest of the community is using it.

## What's Next?

If you're looking for more specific examples, I've put together [a UI Testing cheat sheet]({% post_url 2015-09-14-ui-testing-cheat-sheet %}). The post uses an [open source app](https://github.com/joemasilotti/UI-Testing-Cheat-Sheet) to run all of the assertions. Check it out and fire up Xcode for some practice!
