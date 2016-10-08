import UIKit

class ViewController: UIViewController {
        
    @IBOutlet weak var brandLabel: UILabel!
    var guitar: Guitar?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        brandLabel.text = guitar?.brand
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
