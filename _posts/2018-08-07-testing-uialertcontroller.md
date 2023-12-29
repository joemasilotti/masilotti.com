---
title: How to Test UIAlertController
date: 2018-08-07
description: Learn how to test UIAlertController with protocols, mocks, and dependency injection. No swizzling required.
---

Introduced in iOS 9, [`UIAlertController`](https://developer.apple.com/reference/uikit/uialertcontroller) is the quickest way to present alerts and action sheets to users on iOS. Powered by a simple, straightforward API, you can get something on the screen in just a few lines of code. However, overly hiding internal architecture, namely action handlers, makes testing this class quite difficult. Let’s learn how to test `UIAlertController` with protocols, mocks, and dependency injection. No swizzling required.

## The API

A brief reminder of what we are working with.

```swift
let alert = UIAlertController(title: "Alert Title",
                              message: "Alert message.",
                              preferredStyle: .alert)

let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] (_) in
    self?.confirm()
}
alert.addAction(confirmAction)

let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
alert.addAction(cancelAction)

controller.present(alert, animated: true, completion: nil)
```

In description, you set the title and message, add some actions, then present the alert on a `UIViewController`.

## What to test

Even in this tiny example I see four things that should be tested:

1. The alert's title and message
1. The alert's button titles
1. The action performed when a button is tapped
1. The controller the alert was presented on

Let's walk through these step by step.

### 1. The alert's title and message

To verify these we will need a reference to the assigned values under test. An initial scan of [the docs](https://developer.apple.com/reference/uikit/uialertcontroller) looks promising as we can access the alert's `title` and `message` directly.

```swift
expect(alert.title).to(equal("Alert Title"))
expect(alert.messge)to(equal("Alert message."))
```

### 2. The alert's button titles

There is also an `actions()` method that returns a list of all the `UIAlertAction` instances we created. [Those docs](https://developer.apple.com/documentation/uikit/uialertaction) deliver again, providing `title`.

```swift
expect(alert.actions.count).to(equal(2))
expect(alert.actions.first?.title).to(equal("Confirm"))
expect(alert.actions.last?.title).to(equal("Cancel"))
// or
expect(alert.actions.map({ $0.title })).to(equal(["Confirm", "Cancel"]))
```

### 3. The action performed when a button is tapped

Ideally, `UIAlertAction` would expose the attached `handler`. Then we could execute it under test and verify the correct behvaiour. But it doesn't, so we need to get creative.

## How to test

Our first step is to keep track of the added actions and handlers.

One approach is to swizzle the calls to `addAction()` and save the parameters via associated objects. [Quality Coding has an excellent article (and plug-and-play library) on how and why (not) to do this](https://qualitycoding.org/testing-uialertcontroller/).

A second take "wraps" `UIAlertController` in a new class responsible for building and presenting the alert. This abstracts the existing Apple API, enabling us to store and reference parameters for later use (hint: in the tests!).

### `AlertPresenter`

At a minimum, the class needs to do three things: add actions, present the alert, and retrieve stored action handlers. Each can be accomplished with their own method and saving a reference to each `UIAlertAction` in a dictionary.

```swift
typealias AlertHandler = (UIAlertAction) -> Void

class AlertPresenter {
    private var actionHandlers = [UIAlertAction: AlertHandler]()

    func addAction(titled title: String,
                   style: UIAlertAction.Style,
                   handler: AlertHandler?) {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        actionHandlers[action] = handler
    }

    func present(title: String, message: String, on controller: UIViewController) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        actionHandlers.keys.forEach({ alert.addAction($0) })
        controller.present(alert, animated: false, completion: nil)
    }

    func handler(for action: UIAlertAction) -> AlertHandler? {
        return actionHandlers[action]
    }
}
```
