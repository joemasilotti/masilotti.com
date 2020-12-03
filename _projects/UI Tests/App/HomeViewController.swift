import UIKit

class HomeViewController: UIViewController {
    @IBOutlet private weak var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
    }

    @IBAction func showText() {
        textLabel.isHidden = !textLabel.isHidden
    }
}
