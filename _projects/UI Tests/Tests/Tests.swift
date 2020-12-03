@testable import App
import XCTest

class Tests: XCTestCase {
    func testTappingAButton() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard
            .instantiateViewController(identifier: "Home")
            as! HomeViewController
        controller.loadViewIfNeeded()

        controller.toggleTextButton.sendActions(for: .touchUpInside)

        XCTAssertFalse(controller.textLabel.isHidden)
    }

    func testPushingAViewController() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard
            .instantiateInitialViewController() as? UINavigationController
        let homeViewController = navigationController?
            .topViewController as! HomeViewController
        homeViewController.loadViewIfNeeded()

        homeViewController.pushDetailButton
            .sendActions(for: .touchUpInside)
        RunLoop.current.run(until: Date())

        XCTAssertEqual(navigationController?.viewControllers.count, 2)
        XCTAssert(navigationController?.topViewController is DetailViewController)
    }

    func testPresentingAModalViewController() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard
            .instantiateInitialViewController() as? UINavigationController
        let homeViewController = navigationController?
            .topViewController as! HomeViewController

        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        homeViewController.loadViewIfNeeded()

        homeViewController.presentModalButton
            .sendActions(for: .touchUpInside)
        RunLoop.current.run(until: Date())

        XCTAssertNotNil(navigationController?.presentedViewController)
        XCTAssert(navigationController?.presentedViewController is ModalViewController)
    }
}
