import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var toggleTextButton: UIButton!
    @IBOutlet weak var pushDetailButton: UIButton!
    @IBOutlet weak var presentModalButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
    }

    @IBAction func showText() {
        textLabel.isHidden = !textLabel.isHidden
    }
}
