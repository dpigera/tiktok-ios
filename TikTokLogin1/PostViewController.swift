import UIKit
import WebKit

class PostViewController: UIViewController {
    private var chooseFileButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Post Reel"
        self.view.backgroundColor = .white
        navigationItem.hidesBackButton = false
        
        let backButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .black
     
        setupChooseFileButton()
    }
    
    private func setupChooseFileButton() {
            chooseFileButton = UIButton(type: .system)
            chooseFileButton.setTitle("Choose From Library", for: .normal)
            chooseFileButton.setTitleColor(.black, for: .normal)
            chooseFileButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            chooseFileButton.addTarget(self, action: #selector(chooseFileTapped), for: .touchUpInside)
            
            // Styling identical to Logout button
            chooseFileButton.layer.borderWidth = 2
            chooseFileButton.layer.borderColor = UIColor.black.cgColor
            chooseFileButton.layer.cornerRadius = 10
            chooseFileButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

            chooseFileButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(chooseFileButton)

            // Center the button on the screen
            NSLayoutConstraint.activate([
                chooseFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                chooseFileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                chooseFileButton.widthAnchor.constraint(equalToConstant: 250),
                chooseFileButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

        @objc private func chooseFileTapped() {
            print("Choose From Library button tapped!")
            // You can later add UIImagePickerController or a file picker here
        }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
