---
title: Getting started with UI Testing in Xcode
date: 2015-06-29
description: How to navigate around an lightly documented but powerful framework in Xcode 12.
---

Apple finally decided to double down on user interface testing at WWDC 2015. Let's take a deep dive into the current API and see what we find.

![Xcode UI Testing](/assets/images/ui-testing-xcode-7/xcode-testing.png){:standalone .unstyled}

## Background

I’ve been testing on iOS for a few years now. Before starting at [BeerMenus](https://www.beermenus.com), I spent two years at [Pivotal Labs](http://pivotallabs.com). Pivots, as we like to be called, take testing seriously. Being a [test-driven development](https://en.wikipedia.org/wiki/Test-driven_development) firm (or TDD firm), Pivots take the time to test every nook and cranny of an app or a website. While specific code coverage numbers aren't a priority, they easily comprise 95% of most, if not all, projects.

### Cedar

The only way to test an iOS app back with Xcode 4 was OCUnit, which left much to be desired. Pivots used their expertise in [behavior-driven development](https://en.wikipedia.org/wiki/Behavior-driven_development) frameworks and set out to create their own - and [Cedar](https://github.com/pivotal/cedar) was born.

Cedar is an excellent framework for creating BDD-style tests with full support for matchers and fakes. While Xcode 7 is not yet fully supported, Pivotal is [tracking their work on a branch](https://github.com/pivotal/cedar/tree/Xcode7) and is expected to release something soon. I’ve been using Cedar to test every iOS app I’ve worked on since drinking the TDD Kool Aid. I’ve even started to use it to feature test controllers, but that is a topic for another time.

Using Cedar alone doesn’t give me the end-to-end coverage I have grown to appreciate when working in Ruby on Rails. I can’t reliably spin up the app and tap through a few screens. Understandably so, Cedar wasn’t made for that. To fill the gap a number of players have created their own third-party feature testing frameworks.

### Third party experiments

[Frank](https://github.com/TestingWithFrank/Frank), [KIF](https://github.com/kif-framework/KIF), [Subliminal](https://github.com/inkling/Subliminal), and Apple's [UIAutomation](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/UsingtheAutomationInstrument/UsingtheAutomationInstrument.html), I’ve tried them all. You can read more about why they all leave a lot to be desired in my [breakdown of feature testing frameworks](https://github.com/joemasilotti/ios-feature-testing). It’s not the developers' fault, it’s Apple’s limiting openness when it comes to testing. This makes each of these frameworks nothing more than a series of monkey patches on top of already broken tools.

Without getting into too much detail:

* Frank has long been abandoned
* KIF breaks with every major iOS revision
* Subliminal can’t be run reliably from the command line
* UIAutomation is written in JavaScript and clunky

I worked on six separate apps during my time at Pivotal and tried a different framework for each one. I’ve even [contributed to both KIF](https://github.com/kif-framework/KIF/commits?author=joemasilotti) and [Frank](https://github.com/TestingWithFrank/Frank/commits?author=joemasilotti) because I *wanted* these frameworks to succeed. Unfortunately it just isn’t possible without support from Apple.

## WWDC 2015

![WWDC 2015](/assets/images/ui-testing-xcode-7/wwdc.png){:standalone .unstyled}

Exciting news came this year at WWDC: the [introduction of User Interface Testing](https://developer.apple.com/videos/wwdc/2015/?id=102) during the Platforms State of the Union.

> Xcode 7 introduces user interface testing, ensuring that changes you make in code don’t show up as unwanted changes to your users.

Wil Turner and Brooke Callahan present the new framework in session 406, [UI Testing in Xcode](https://developer.apple.com/videos/wwdc/2015/?id=406). If you haven't watched it yet, I recommend you take a look. They demo a simple task manager application and highlight some of the APIs and features included with the tools.

![WWDC Demo](/assets/images/ui-testing-xcode-7/wwdc-demo.png){:standalone .unstyled}

UI Testing's big claim to fame is "Recording." After you have a working application, you tap a big red circle and start tapping around in your app. As you interact with your app, code is automatically generated to reproduce your flow. In theory, you are then able to run the newly created test and watch as your app repeats your actions.

## UI Testing in practice

Claims and demos are one thing, but how does the framework work in the real world?

### Documentation

![XCTest documentation in Dash](/assets/images/ui-testing-xcode-7/documentation.png){:standalone .unstyled}

UI Testing lives in the `XCTest` framework and adds four new classes, one new protocol, and three new constants.

#### Launching the App - `XCUIApplication`

This is the main hook for launching your testable application. You create a new one, `XCUIApplication()` and then call `launch()` on it. If you add a new UI Test target to your app you will see an example in the template. Before launching you can set specific arguments or environment variables by setting the `-launchArguments` or `-launchEnvironment` properties, respectively. This creates a nice layout for telling your HTTP client, for example, to hit a mock server when under test.

```swift
let app = XCUIApplication()
app.launchArguments = ["USE_MOCK_SERVER"]
app.launch()
```

You can also `-terminate` your app, but I haven't found a use for that just yet.

#### Accessing the device - `XCUIDevice`

You can create a new instance of this object with `+sharedDevice`. The only publicly accessible property is `-orientation` which returns the usual `UIDeviceOrientation` enum. Even though this is a read/write property, setting it does not update the interface of the simulator. I'm not sure if this is a bug in the beta I was using though.

#### Querying for elements - `XCUIElementQuery`

This is the class your UI tests will use the most. You use it to build queries to locate your elements. Remember `app.tableViews[0].cells[0]` from UIAutomation? Well, this looks almost identical and is used in a very similar fashion.

```swift
app.tables.element.cells.element(boundBy: 4).tap()
```

Each call down the stack returns another query object that can be chained together. This gives you precise control to target specific views in your app without much overhead. By referencing `-element` you are essentially saying, "I know there is only one of these, I want that one." You can also reference objects in the arrays by accessibility label.

```swift
app.tables.element.cells["Call Mom"].buttons["More"].tap()
```

These convenience methods work by calling `element(matching: identifier:)` with `XCUIElementTypeAny` and the string you passed in. Check out `XCUIElementType` for all the options if you want finer grain control.

#### Interacting with elements - `XCUIElement`

> Elements are objects encapsulating the information needed to dynamically locate a user interface element in an application. Elements are described in terms of queries. **When an event API is called, the element will be resolved.** If zero or multiple matches are found, an error will be raised.

This means that you create an `XCUIElementQuery`, which give you *references* to elements. Not until you actually try to interact with them does the framework actually look through the app's hierarchy to find it. This has huge advantages for keeping your tests [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) - you can keep a reference to a query and reuse it at different points of the test. The element will only be found during the interaction, saving you the effort to have to drill down again.

Interactions are named appropriately and do what you would expect. For example, in iOS you can use `tap()`, `press(forDuration:)`, `swipeUp()`, and `twoFingerTap(0`. If you are testing an OS X app you can use the `click*()` counterparts.

### Assertions

What would a testing framework be without assertions? Since UI testing is just an extension of XCTest, all of the existing assertions already work. This means you have access to the macros like `XCTAssert()`, `XCTAssertEquals()`, and `XCTAssertNotNil()`.

#### Checking if an element exists

One might be tempted to use a not-nill assertion on an element to see if it exists or not.

```swift
XCTAssertNotNil(app.buttons["Submit"])
```

However, `-elementMatchingType:identifier:` *always* returns an object. It is not until that is resolved that it decides if an element actually matches the query. This means this test will *always* pass.

Instead, call `-exists` on the element and wrap that in an assertion.

```swift
XCTAssert(app.buttons["Submit"].exists)
```

Another way to approach assertions is to not use any at all. While running the tests if a resolved query doesn't match an element the test will automatically fail. Make sure to turn off `XCTestCase.continueAfterFailure` in your `setUpWithError()` method.

### Debugging

![Table with five cells](/assets/images/ui-testing-xcode-7/table-with-five-cells.png){:standalone .unstyled.max-w-md}

When printing an `XCUIElementQuery` from the console, you are presented with a lot of noise. Imagine a table with five cells labeled "One" through "Five". To target the cell labeled "Three" you could print something like this (some keys omitted for clarity):

```swift
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
```

This is huge insight into how the framework is locating your elements. Notice `tables()` in the first input/output loop returns the table that fills this iPhone 6 simulator. Then drilling down to `cells()` returned all of the cells. Finally, the text query only returned the one element at the end. **If you don't see the "Output" key at the end of a query it means the framework did not find your element.**

## Is it ready?

As of Xcode 12, UI Testing shows promise. It's more reliable than ever, the querying engine is powerful, and it's more future-proof than any third-party library can realistically be.

### How to wait for elements with UI Testing

Imagine we are writing a UI test around loading some content off the web. Since it won't be present immediately we will need to set up some expectations for the event. This isn't new, it was introduced in Xcode 6, but **now it works with UI Testing**.

```swift
let label = app.staticTexts["Hello, world!"]
XCTAssert(label.waitForExistence(timeout: 5))
```

If you've been following this post you can appreciate how short that is! You used to have to create an `NSPredicate`; this would easily be twice as many lines of code.

If five seconds pass before the expectation is met then the test will fail. You can also pass a handler block in that gets called when the expectation fails or times out.

> **Pro Tip**: Learn how to [extract this into a test helper]({% post_url 2015-09-21-xctest-helpers %}).

### Pinching and zooming

You can use these new methods to manipulate maps. For example, to zoom in on the center of a `MKMapView`:

```swift
app.maps.element.pinch(withScale: 1.5, velocity: 1)
```

According to the [documentation for UI Testing](https://developer.apple.com/documentation/xctest/xcuielement/1618669-pinch), the `scale` parameter will determine a zoom out or zoom in gesture.

> Use a scale between 0 and 1 to "pinch close" or zoom out and a scale greater than 1 to "pinch open" or zoom in.

Also note that the `velocity` parameter has a restrictions as well. If you are zooming out (a scale between 0 and 1) you the velocity must be less than zero.

By using a combination of pinches and swipes, you can narrow in on a specific address on your map.

### Interacting with pickers

First, let's get a picker on the screen. Then populate it with ten items, one for each iPhone model released so far. I've added this [boilerplate to a GitHub project](https://github.com/joemasilotti/UIPickerViewTester) if you don't want to write the code yourself.

![UIPickerView Example](/assets/images/ui-testing-xcode-7/picker-example.png){:standalone .unstyled}

With the addition of `adjust(toPickerWheelValue:)` on `XCUIElement`, selecting an item is pretty trivial. Just make sure you call it on an actual picker or the framework will raise an exception.

```swift
app.pickerWheels.element.adjust(toPickerWheelValue: "iPhone 3GS")
XCTAssert(app.staticTexts["iPhone 3GS"].exists)
```

Note that this only works with a single picker on the screen. If you have more than one you will have to specify the picker explicitly where I called `element`.

> [Relevant documentation on interacting with pickers](https://developer.apple.com/documentation/xctest/xcuielement/1618672-adjust)

### Hardware buttons

If your app adds custom behavior to the volume controls than this addition is for you. After referencing the shared device singleton, we can press different hardware buttons.

```swift
XCUIDevice.sharedDevice.pressButton(XCUIDevice.Button.home)
```

### Recording

Attempting to record particular events doesn't register at all. For example, any interaction with `WKWebView` must be written manually. And good luck interacting with system alerts when asked for location authorization.

Overall I think that everyone should at least try out UI Testing on their own project. It offers new ways of validating your application and a second level of test assertions which any app in the App Store can benefit from. I'm excited to farther integrate it into the projects I work on everyday and look forward to seeing how the rest of the community is using it.

## What's next?

If you're looking for more specific examples, I've put together [a UI Testing cheat sheet]({% post_url 2015-09-14-ui-testing-cheat-sheet %}). The post uses an [open source app](https://github.com/joemasilotti/UI-Testing-Cheat-Sheet) to run all of the assertions. Check it out and fire up Xcode for some practice!
