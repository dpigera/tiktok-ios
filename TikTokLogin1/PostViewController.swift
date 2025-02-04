import UIKit
import WebKit
import PhotosUI
import AVKit
import MobileCoreServices

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var chooseFileButton: UIButton!
    private var videoPreviewView: UIView!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playButton: UIButton!
    private var stopButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Post Reel"
        self.view.backgroundColor = .white
        navigationItem.hidesBackButton = false
        
        let backButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .black
     
        setupChooseFileButton()
        setupVideoPreview()
        setupPlaybackButtons()
    }
    
    private func setupVideoPreview() {
        videoPreviewView = UIView()
        videoPreviewView.backgroundColor = .black
        videoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        videoPreviewView.isHidden = true
        view.addSubview(videoPreviewView)
        
        NSLayoutConstraint.activate([
            videoPreviewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoPreviewView.topAnchor.constraint(equalTo: chooseFileButton.bottomAnchor, constant: 20),
            videoPreviewView.widthAnchor.constraint(equalToConstant: 300),
            videoPreviewView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupPlaybackButtons() {
        playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.backgroundColor = .black
        playButton.layer.cornerRadius = 10
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.isHidden = true
        view.addSubview(playButton)

        stopButton = UIButton(type: .system)
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .red
        stopButton.layer.cornerRadius = 10
        stopButton.addTarget(self, action: #selector(stopVideo), for: .touchUpInside)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.isHidden = true
        view.addSubview(stopButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            playButton.topAnchor.constraint(equalTo: videoPreviewView.bottomAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 40),

            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            stopButton.topAnchor.constraint(equalTo: videoPreviewView.bottomAnchor, constant: 20),
            stopButton.widthAnchor.constraint(equalToConstant: 100),
            stopButton.heightAnchor.constraint(equalToConstant: 40)
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
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [UTType.movie.identifier] // Allow video selection
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // UIImagePickerController Delegate: Handles selected video
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                setupVideoPlayer(with: videoURL)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        private func setupVideoPlayer(with url: URL) {
            player = AVPlayer(url: url)
            playerLayer?.removeFromSuperlayer() // Remove previous player if exists

            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = videoPreviewView.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            videoPreviewView.layer.addSublayer(playerLayer!)

            videoPreviewView.isHidden = false
            playButton.isHidden = false
            stopButton.isHidden = false
        }

        @objc private func playVideo() {
            player?.play()
        }

        @objc private func stopVideo() {
            player?.pause()
            player?.seek(to: CMTime.zero) // Reset to the beginning
        }
}
