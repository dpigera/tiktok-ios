import UIKit

class MyFavoritesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.backgroundColor = .white
        
        // Set the title
        title = "Saved Videos"
        
        // Example label
        let label = UILabel()
        label.text = "Saved Videos"
        label.textAlignment = .center
        label.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
        view.addSubview(label)
    }
}
