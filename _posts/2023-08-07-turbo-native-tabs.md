---
title: Turbo Native tabs
date: 2023-08-07
description: Learn how to add a native tab bar to a Turbo Native app. And some hints for fixing common gotchas.
---

{% include warning.liquid %}

[Turbo Native]({% post_url 2021-05-14-turbo-ios %}) promises feature parity with your Rails app via web-powered screens. But it doesn’t have anything special built in to handle native components, like a tab bar.

This row of buttons along the bottom of an iOS app is a common UX pattern. And it makes the app feel more native. Take, for example, the built in Clock app.

Each tab is a different use case or feature.

![Tabs in the Clock app](/assets/images/turbo-native-tabs/clock.app-tabs.png){:standalone .unstyled}

A big benefit of Turbo Native is that you have full access to underlying iOS SDKs. So adding tabs is less about twisting the framework to do our bidding. And more _wrapping_ our integration in some additional Swift code.

Let’s add tabs to a Turbo Native app!

## A new Xcode project

We’ll start from scratch. First, download a copy of Xcode from the [App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12).

Open Xcode and create a new project via File → New → Project…

Select App from the iOS tab and click Next.

![New iOS App Xcode project](/assets/images/turbo-native-tabs/new-xcode-project.png){:standalone}

Name your project whatever you want – I named mine "Tabs". Make sure Interface is set to Storyboard and click Next.

![New Xcode project options](/assets/images/turbo-native-tabs/xcode-project-settings.png){:standalone}

Finally, select a location to save your project. I threw mine on my desktop for now.

## UITabBarController

With a new project to build on lets explore how tabs on iOS work.

Open `Main.storyboard` (just "Main" in the project explorer) and click View → Inspectors → Identity. Select the "View Controller" layer from the left and change the Class property from `ViewController` to `UITabBarController`.

![UITabBarController root class](/assets/images/turbo-native-tabs/uitabbarcontroller-root-class.png){:standalone}

This tells iOS to initialize and load a tab bar controller when the app is launched. Which we can then access in our scene delegate.

Open `SceneDelegate.swift` and replace everything in the file with the following:

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var tabBarController: UITabBarController!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        tabBarController = window?.rootViewController as? UITabBarController
    }
}
```

Now we have a reference to our tab bar controller that we can use throughout this class.

### Adding tabs

We won’t add tabs directly to `UITabBarController`. Instead, we set the `viewControllers` property to an array of view controllers. Under the hood, this creates a new tab for each controller.

Add the following after setting the `tabBarController` property above. This creates two controllers, each with different colors and titles, and adds them to the tab bar.

```swift
let vc1 = UIViewController()
vc1.view.backgroundColor = .lightGray
vc1.title = "VC1"

let vc2 = UIViewController()
vc2.view.backgroundColor = .darkGray
vc2.title = "VC2"

tabBarController.viewControllers = [vc1, vc2]
```

Run the app via Product → Run and you should see two tabs at the bottom of the screen, VC1 and VC2. Tapping each will load the background color we set above.

Note how the title of the tab corresponds to the title of the view controller. We get this for free but it can also be overridden with a [custom tab](https://developer.apple.com/documentation/uikit/uitabbaritem).

## Integrating Turbo Native

With a basic understanding and scaffolding for tabs, let’s integrate the Turbo Native framework.

First, let’s add add turbo-ios to our app as a Swift package. Click File → Add Packages… and enter the following URL in the search box in the upper right:

```
https://github.com/hotwired/turbo-ios
```

![turbo-ios Swift package](/assets/images/turbo-native-tabs/turbo-ios-swift-package.png){:standalone}

Click Add Package and on the next screen click Add Package again.

### TurboNavigationController

With the Swift package integrated, let's scaffold the minimum integration required to get Turbo Native working.

I’m borrowing code from my [Turbo Native in 15 minutes video](https://www.youtube.com/watch?v=83wOvrNtZX4) and [custom Xcode starter project](https://github.com/joemasilotti/TurboNativeXcodeTemplate). Feel free to dive into either of those for more background on how this all works.

Create a new Swift file named `TurboNavigationController` and replace its contents with the following. This creates a navigation stack with basic handling for tapping links.

```swift
import Turbo
import UIKit
import WebKit

class TurboNavigationController: UINavigationController {
    func visit(url: URL) {
        let proposal = VisitProposal(url: url, options: VisitOptions())
        visit(proposal)
    }

    // MARK: Private

    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        // Identifies Turbo Native apps with `turbo_native_app?` helper in Rails.
        configuration.applicationNameForUserAgent = "Turbo Native iOS"

        let session = Session(webViewConfiguration: configuration)
        session.delegate = self
        return session
    }()

    private func visit(_ proposal: VisitProposal) {
        let visitable = VisitableViewController(url: proposal.url)
        pushViewController(visitable, animated: true)
        session.visit(visitable, options: proposal.options)
    }
}

// MARK: SessionDelegate

extension TurboNavigationController: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        visit(proposal)
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        print("Error visiting page: \(error.localizedDescription)")
    }

    func sessionWebViewProcessDidTerminate(_ session: Session) {
        fatalError("Web view process terminated")
    }
}
```

We will use a different instance of this class for each tab we want to show.

## Connect Turbo Native to the tab bar

With a basic Turbo Native integration in place we can start incorporating it into our tab bar.

Back in `SceneDelegate.swift`, create a private property to hold our navigation controllers.

```swift
private let turboNavigationControllers = [
    TurboNavigationController(),
    TurboNavigationController(),
    TurboNavigationController()
]
```

Then, assign this property to the tab bar controller like before.

```swift
tabBarController.viewControllers = turboNavigationControllers
```

Unfortunately, running the app shows a black screen. We still need to tell the navigation controllers to start visiting pages.

### Perform the visit

After assigning the `viewControllers` property, kick off a visit to the first tab. Here I’m pointing to the demo server used in the turbo-ios repo.

```swift
let tab1URL = URL(string: "https://turbo-native-demo.glitch.me")!
turboNavigationControllers[0].visit(url: tab1URL)
```

If all went well you should see a tab all the way to the left titled “Turbo Native Demo”.

There are actually two other tabs but you can’t see them because they have no title! Try clicking in the blank space to the right and note how a black screen loads. What gives?

![Three tab example](/assets/images/turbo-native-tabs/three-tabs.png){:standalone}

### Visiting other tabs

Just like we had to _visit_ the first tab, we need to do the same for the others.

Add the following code to make sure we kick off a visit when accessing the other two tabs. Here I’m taking advantage of two other paths in the demo server to load different screens.

```swift
let tab2URL = tab1URL.appending(path: "/one")
turboNavigationControllers[1].visit(url: tab2URL)

let tab3URL = tab1URL.appending(path: "/two")
turboNavigationControllers[2].visit(url: tab3URL)
```

Your entire `SceneDelegate.swift` file should now look like this:

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var tabBarController: UITabBarController!
    private let turboNavigationControllers = [
        TurboNavigationController(),
        TurboNavigationController(),
        TurboNavigationController()
    ]

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        tabBarController = window?.rootViewController as? UITabBarController
        tabBarController.viewControllers = turboNavigationControllers

        let tab1URL = URL(string: "https://turbo-native-demo.glitch.me")!
        turboNavigationControllers[0].visit(url: tab1URL)

        let tab2URL = tab1URL.appending(path: "/one")
        turboNavigationControllers[1].visit(url: tab2URL)

        let tab3URL = tab1URL.appending(path: "/two")
        turboNavigationControllers[2].visit(url: tab3URL)
    }
}
```

## Ideas for improvement

This straightforward approach to tabs has two opportunities for improvement.

### Magic numbers

The relationship between the URLs and navigation controllers forces us to use some magic numbers. Which if not handled perfectly, could cause an index out of bounds error.

Ideally, we have a single source of truth and the other is inferred from that. For example, an array of `URL` instances that dynamically creates a `TurboNavigationController` for each. This would involve a small refactor to the navigation controller to _inject_ the URL.

### Extra server requests

Second, every time the app is launched, _three_ requests hit the server, one for each tab. Even if the user never visits the second tab it will **always** be loaded.

One solution to this is to implement [`UITabBarControllerDelegate`](https://developer.apple.com/documentation/uikit/uitabbarcontrollerdelegate) and listen for when the user changes tabs. Refactoring this to expose the correct URL is a great exercise to explore!
