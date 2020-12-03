@testable import App
import XCTest

class Tests: XCTestCase {
    func testTappingAButton() throws {
        let controller = loadInitialViewController() as! HomeViewController
        controller.toggleTextButton.tap()
        XCTAssertFalse(controller.textLabel.isHidden)
    }

    func testPushingAViewController() throws {
        let controller = loadInitialViewController() as! HomeViewController

        controller.pushDetailButton.tap()

        XCTAssertEqual(controller.navigationController?.viewControllers.count, 2)
        XCTAssert(controller.navigationController?.topViewController is DetailViewController)
    }

    func testPresentingAModalViewController() throws {
        let window = UIWindow()
        let controller = loadInitialViewController(in: window)
            as! HomeViewController

        controller.presentModalButton.tap()

        XCTAssertNotNil(controller.navigationController?.presentedViewController)
        XCTAssert(controller.navigationController?.presentedViewController is ModalViewController)
    }
}

extension XCTestCase {
    func loadInitialViewController(in window: UIWindow? = nil) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard
            .instantiateInitialViewController() as? UINavigationController
        let topViewController = navigationController?.topViewController

        if let window = window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }

        topViewController?.loadViewIfNeeded()
        return topViewController
    }
}

extension UIButton {
    func tap() {
        sendActions(for: .touchUpInside)
        RunLoop.current.run(until: Date())
    }
}
