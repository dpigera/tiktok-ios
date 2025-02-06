import UIKit
import WebKit
import PhotosUI
import AVKit
import MobileCoreServices
import AVFoundation

class ClipViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var chooseFileButton: UIButton!
    private var videoPreviewView: UIView!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playButton: UIButton!
    private var stopButton: UIButton!
    private var uploadButton: UIButton!
    private var selectedVideoURL: URL?
    private var loadingIndicator: UIActivityIndicatorView!
    
    private let videoProcessor = VideoProcessor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add this audio session configuration
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
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
            videoPreviewView.widthAnchor.constraint(equalToConstant: 300)
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

        uploadButton = UIButton(type: .system)
        uploadButton.setTitle("Upload", for: .normal)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.backgroundColor = .systemGreen
        uploadButton.layer.cornerRadius = 10
        uploadButton.addTarget(self, action: #selector(uploadVideo), for: .touchUpInside)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.isHidden = true
        view.addSubview(uploadButton)

        // Create and configure loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        uploadButton.addSubview(loadingIndicator)
        
        // Center the loading indicator in the upload button
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: uploadButton.centerYAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: uploadButton.leadingAnchor, constant: 10)
        ])

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -120),
            playButton.topAnchor.constraint(equalTo: videoPreviewView.bottomAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 40),

            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: videoPreviewView.bottomAnchor, constant: 20),
            stopButton.widthAnchor.constraint(equalToConstant: 100),
            stopButton.heightAnchor.constraint(equalToConstant: 40),

            uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 120),
            uploadButton.topAnchor.constraint(equalTo: videoPreviewView.bottomAnchor, constant: 20),
            uploadButton.widthAnchor.constraint(equalToConstant: 100),
            uploadButton.heightAnchor.constraint(equalToConstant: 40)
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
            self.selectedVideoURL = videoURL // Store the selected video URL
            setupVideoPlayer(with: videoURL)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func setupVideoPlayer(with url: URL) {
        // Get video dimensions
        let asset = AVAsset(url: url)
        let tracks = asset.tracks(withMediaType: .video)
        if let videoTrack = tracks.first {
            let size = videoTrack.naturalSize
            let transform = videoTrack.preferredTransform
            
            // Apply transform to handle video orientation
            let videoRect = CGRect(origin: .zero, size: size).applying(transform)
            let videoWidth: CGFloat = abs(videoRect.width)
            let videoHeight: CGFloat = abs(videoRect.height)
            
            // Calculate aspect ratio and update preview height
            let aspectRatio = videoHeight / videoWidth
            let previewWidth: CGFloat = 300 // Match the width constraint we set
            let previewHeight = previewWidth * aspectRatio
            
            // Update videoPreviewView constraints
            videoPreviewView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.isActive = false
                }
            }
            
            videoPreviewView.heightAnchor.constraint(equalToConstant: previewHeight).isActive = true
        }
        
        player = AVPlayer(url: url)
        playerLayer?.removeFromSuperlayer() // Remove previous player if exists
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        
        // Show the views
        videoPreviewView.isHidden = false
        playButton.isHidden = false
        stopButton.isHidden = false
        uploadButton.isHidden = false
        
        // Force layout update
        view.layoutIfNeeded()
        
        // Update player layer frame after layout
        playerLayer?.frame = videoPreviewView.bounds
        videoPreviewView.layer.addSublayer(playerLayer!)
        
        // Add observer for layout changes
        videoPreviewView.addObserver(self, forKeyPath: "bounds", options: [.new], context: nil)
    }

    @objc private func playVideo() {
        player?.play()
    }

    @objc private func stopVideo() {
        player?.pause()
        player?.seek(to: CMTime.zero) // Reset to the beginning
    }

    @objc private func uploadVideo() {
        guard let videoURL = selectedVideoURL else {
            showAlert(message: "No video selected")
            return
        }
        
        // Show loading state
        uploadButton.setTitle("Processing...", for: .normal)
        uploadButton.isEnabled = false
        uploadButton.backgroundColor = .gray
        loadingIndicator.startAnimating()
        
        // Define time ranges for clips with descriptions
        let timeRanges = [
            CMTimeRange(start: CMTime(seconds: 2.3, preferredTimescale: 600),
                       end: CMTime(seconds: 17.0, preferredTimescale: 600)),
            CMTimeRange(start: CMTime(seconds: 21.35, preferredTimescale: 600),
                       end: CMTime(seconds: 29.26, preferredTimescale: 600)),
            // CMTimeRange(start: CMTime(seconds: 53.35, preferredTimescale: 600),
            //            end: CMTime(seconds: 61.72, preferredTimescale: 600)),
            // CMTimeRange(start: CMTime(seconds: 71.60, preferredTimescale: 600),
            //            end: CMTime(seconds: 83.78, preferredTimescale: 600)),
            // CMTimeRange(start: CMTime(seconds: 86.92, preferredTimescale: 600),
            //            end: CMTime(seconds: 96.40, preferredTimescale: 600))
        ]
        
        // Process video
        videoProcessor.clipAndStitchVideo(from: videoURL, timeRanges: timeRanges) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let processedVideoURL):
                    // Stop current playback if any
                    self.player?.pause()
                    self.player = nil
                    self.playerLayer?.removeFromSuperlayer()
                    
                    // Update video preview with processed video
                    self.setupVideoPlayer(with: processedVideoURL)
                    self.showAlert(message: "Video processing completed!")
                    
                case .failure(let error):
                    print("Processing error: \(error)")
                    self.showAlert(message: "Video processing failed: \(error.localizedDescription)")
                }
                self.resetUploadButton()
            }
        }
    }
    
    // Add helper method to reset upload button
    private func resetUploadButton() {
        uploadButton.setTitle("Upload", for: .normal)
        uploadButton.isEnabled = true
        uploadButton.backgroundColor = .systemGreen
        loadingIndicator.stopAnimating()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Add this method to handle bounds changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            playerLayer?.frame = videoPreviewView.bounds
        }
    }

    deinit {
        videoPreviewView?.removeObserver(self, forKeyPath: "bounds")
    }
}
