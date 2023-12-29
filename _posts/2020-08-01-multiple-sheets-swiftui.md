---
title: How to manage multiple sheets in SwiftUI
date: 2020-08-02
description: A step-by-step journey on how I refactored an app to handle any number of sheets with ObservableObject and an enum.
---

My first SwiftUI post! I recently converted my iOS app [X-Wing AI](https://xwing.app) to SwiftUI and ran into some issues with multiple sheets. Here's my step-by-step journey on how I refactored the code to handle any number of sheets with `ObservableObject` and an enum.

Side note, but it took *way* less time than I had expected to convert the app. And according to Crashlytics I’ve dramatically cut down on crashes.

![100% crash-free users on Crashlytics](/assets/images/multiple-sheets-swiftui/crashlytics.png){:standalone .unstyled}

## A first pass

The app doesn’t do anything too crazy, so I was able to stick to standard SwiftUI paradigms and views for most of it. However, the Settings screen has a bunch of buttons that each present different content modally.

![Screenshot of app with buttons that each open different modals](/assets/images/multiple-sheets-swiftui/settings-screen.png){:standalone .unstyled.max-w-lg}

Each button was added incrementally as it was needed. I created a `@State` property for each possible sheet (6 in total) and tossed a `.sheet` after each button. The essence looked something like this.

My code looked like a hacker’s attempt to brute force a password!

```swift
struct ContentView: View {
    @State var isPresentingSheetOne = false
    @State var isPresentingSheetTwo = false
    // 4 more @State properties

    var body: some View {
        VStack {
            Button("Show sheet #1") {
                self.isPresentingSheetOne = true
            }.sheet(isPresented: $isPresentingSheetOne) {
                Text("Sheet #1 content")
            }

            Button("Show sheet #2") {
                self.isPresentingSheetTwo = true
            }.sheet(isPresented: $isPresentingSheetTwo) {
                Text("Sheet #2 content")
            }

            // 4 more Buttons and sheet() modifiers
        }
    }
}
```

If there were actually only two sheets, this isn’t a terrible approach. Each `Button` is tied directly to its sheet. But with six, things were unwieldy. And there was a lot of repeated boilerplate code.

## Refactoring sheet state to an `enum`

I figured there’s a better way to manage this, but found nothing built into SwiftUI. Every time I added a new sheet I would need to add a new variable.

So I refactored to pull out the different sheet states into its own enum.

```swift
enum SettingsSheetState {
    case none
    case attributions
    case instructions
    // ...
}
```

Then, the view only needed two  `@State` properties: one to reference which sheet is being presented, the other a boolean binding to tell  `.sheet()`  *if* anything is being presented. A property observer got me around having to manually set the boolean every time the enum is set.

```swift
struct SettingsView: View {
    @State var isShowingSheet = false
    @State var sheetState = SheetState.none {
        willSet {
            isShowingSheet = newValue != .none
        }
    }

    var body: some View {
        Button("Instructions") {
            self.sheetState = .instructions
        }
        .sheet(isPresented: $sheet.isShowing) {
            // sheet contents
        }
    }
}
```

Not a bad start! But what about the sheet contents? What’s a sane approach to returning different views based on the state?

### Multiple sheet contents

After receiving some [help on Twitter](https://twitter.com/joemasilotti/status/1288873023337046020?s=20) I ended up with a (slightly gnarly) `if` block. The key was to return `some View` and mark the function as a `@ViewBuilder`. This makes it behave more like `Group` or `VStack` and enables different types of views to be returned. Otherwise I would have had to cast everything to `AnyView`.

> P.S. If you are using Xcode 12 and targeting iOS 14 then this can be a `switch` statement!

```swift
struct SettingsView: View {
    // ...

    var body: some View {
        Button("Instructions") {
            self.sheetState = .instructions
        }.sheet(
            isPresented: $sheet.isShowing,
            content: sheetContent
        )
    }

    @ViewBuilder
    private func sheetContent() -> some View {
        if sheetState == .instructions {
            InstructionsView()
        } else if sheetState == .attributions {
            AttributionsView()
        // else if ...
        } else {
            EmptyView()
        }
    }
}
```

Keeping the body of each `if` to a single line helped keep the code fairly tidy. It wasn’t ideal but it got the job done.


A few hours per week I teach a developer new to SwiftUI how to build an app from scratch. During one of our pair programming sessions they sparked a great idea. What if this was a *single* object?

## Down to a single property

A second pass combined everything into a single `@ObservableObject`.

```swift
class SettingsSheetState: ObservableObject {
    @Published var isShowing = false
    @Published var state = SheetState.none {
        didSet { isShowing = state != .none }
    }
}
```

Now the view can bind directly to the published properties but only keep a single reference to the object.

```swift
struct SettingsView: View {
    @ObservedObject var sheet = SettingsSheetState()

    var body: some View {
        Button("Instructions") {
            self.sheet.state = .instructions
        }.sheet(
            isPresented: $sheet.isShowing,
            content: sheetContent
        )
    }

   // ...
}
```

## Extracting common behavior

This was looking pretty good! But I kept going. What if I could extract some of that common code in `SettingsSheetState` to its own class?

```swift
class SheetState<State>: ObservableObject {
    @Published var isShowing = false
    @Published var state: State? {
        didSet { isShowing = state != nil }
    }
}

class SettingsSheet: SheetState<SettingsSheet.State> {
    enum State {
        case attributions
        case instructions
        // ...
    }
}
```

Now all of our boilerplate lives in `SheetState` and the only responsibility a subclass has is to define the class-wrapped enum! And `SettingsSheet` can be used just like before.

The `<State>` part of `SheetState` is defining a generic type. It doesn’t know, or care, what’s going to be passed to it. It just knows it can be an optional. This is defined in the subclass, `SettingsSheet`, to the enum type.

As a bonus, making `state` optional means we can remove the `.none` from our enum and just check for `nil`.

## Wrapping up

Overall I give this approach a B+.

It solves my main issue of cleanly presenting multiple sheets in SwiftUI. But it creates a different, albeit minor, problem with the ugly if statement. Once you can target iOS 14 and `switch` statements are accessible then this gets bumped up to an A!
