import UIKit
import WebKit
import PhotosUI

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var chooseFileButton: UIButton!
    private var selectedImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Post Reel"
        self.view.backgroundColor = .white
        navigationItem.hidesBackButton = false
        
        let backButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .black
     
        setupChooseFileButton()
        setupSelectedImageView()
    }
    
    private func setupSelectedImageView() {
        selectedImageView = UIImageView()
        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedImageView.isHidden = true
        view.addSubview(selectedImageView)

        NSLayoutConstraint.activate([
            selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedImageView.topAnchor.constraint(equalTo: chooseFileButton.bottomAnchor, constant: 20),
            selectedImageView.widthAnchor.constraint(equalToConstant: 200),
            selectedImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
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
            chooseFileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20), // Moves it below the header
            chooseFileButton.widthAnchor.constraint(equalToConstant: 250),
            chooseFileButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func chooseFileTapped() {
        print("Choose From Library button tapped!")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true // Allows cropping before selecting
        present(imagePicker, animated: true, completion: nil)
        // You can later add UIImagePickerController or a file picker here
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // UIImagePickerController Delegate: Handles selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            selectedImageView.image = selectedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageView.image = originalImage
        }
        
        selectedImageView.isHidden = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    // UIImagePickerController Delegate: Handles cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
