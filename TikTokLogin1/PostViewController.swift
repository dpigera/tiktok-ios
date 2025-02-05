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
    private var uploadButton: UIButton!
    private var selectedVideoURL: URL?
    private var loadingIndicator: UIActivityIndicatorView!

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
        
        // Update upload button appearance
        uploadButton.setTitle("  Uploading...", for: .normal) // Add space for indicator
        uploadButton.isEnabled = false
        uploadButton.backgroundColor = .systemGray
        loadingIndicator.startAnimating()
        
        // Step 1: Get the S3 upload URL
        let urlString = "https://58fa-69-212-112-109.ngrok-free.app/s3url"
        guard let url = URL(string: urlString) else {
            showAlert(message: "Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.resetUploadButton()
                    self.showAlert(message: "Failed to get upload URL: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data,
                      let s3Response = try? JSONDecoder().decode(S3UploadResponse.self, from: data) else {
                    self.resetUploadButton()
                    self.showAlert(message: "Failed to parse response")
                    return
                }
                
                // Step 2: Upload the video to S3
                self.uploadToS3(videoURL: videoURL, uploadURL: s3Response.uploadURL) { result in
                    DispatchQueue.main.async {
                        self.resetUploadButton()
                        
                        switch result {
                        case .success(let publicURL):
                            // First query creator info
                            
                            self.queryCreatorInfo { result in
                                switch result {
                                case .success(_):
                                    // If creator info query succeeds, proceed with TikTok upload
                                    self.uploadToTikTok(videoURL: publicURL) { result in
                                        switch result {
                                        case .success(let message):
                                            self.showAlert(message: "Upload successful!\nTikTok: \(message)")
                                        case .failure(let error):
                                            self.showAlert(message: "TikTok upload failed: \(error.localizedDescription)")
                                        }
                                    }
                                case .failure(let error):
                                    self.showAlert(message: "Creator info query failed: \(error.localizedDescription)")
                                }
                            }
                        case .failure(let error):
                            self.showAlert(message: "Upload failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    private func uploadToS3(videoURL: URL, uploadURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: uploadURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid upload URL"])))
            return
        }
        
        do {
            let videoData = try Data(contentsOf: videoURL)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("video/mp4", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.uploadTask(with: request, from: videoData) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let publicURL = uploadURL.components(separatedBy: "?").first {
                    let originalURL = publicURL
                    let newDomain = "https://egr-demo-bucket.s3.us-east-1.amazonaws.com"

                    if let range = originalURL.range(of: "https://egr-demo-bucket.s3.amazonaws.com") {
                        let updatedURL = originalURL.replacingCharacters(in: range, with: newDomain)
                        completion(.success(updatedURL))
                    } else {
                        print("Original domain not found in URL")
                    }
                    
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate public URL"])))
                }
            }
            task.resume()
            
        } catch {
            completion(.failure(error))
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

    // First, add this struct for the TikTok request
    struct TikTokUploadRequest: Encodable {
        let sourceInfo: SourceInfo
        let postInfo: PostInfo
        
        enum CodingKeys: String, CodingKey {
            case sourceInfo = "source_info"
            case postInfo = "post_info"
        }
        
        struct SourceInfo: Encodable {
            let videoUrl: String
            let source: String
            
            enum CodingKeys: String, CodingKey {
                case videoUrl = "video_url"
                case source
            }
        }
        
        struct PostInfo: Encodable {
            let privacyLevel: String
            let disableComment: Bool
            let title: String
            let videoCoverTimestampMs: Int
            let disableStitch: Bool
            let disableDuet: Bool
            
            enum CodingKeys: String, CodingKey {
                case privacyLevel = "privacy_level"
                case disableComment = "disable_comment"
                case title
                case videoCoverTimestampMs = "video_cover_timestamp_ms"
                case disableStitch = "disable_stitch"
                case disableDuet = "disable_duet"
            }
        }
    }

    // Then modify the success case in uploadToS3 completion handler:
    private func uploadToTikTok(videoURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.showAlert(message: "Upload successful!\nPublic URL: \(videoURL)")
        let tiktokUploadURL = "https://open.tiktokapis.com/v2/post/publish/video/init/"
        guard let url = URL(string: tiktokUploadURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid TikTok API URL"])))
            return
        }
        
        // Get access token from UserDefaults
        guard let accessToken = UserDefaults.standard.string(forKey: "TikTokAccessToken") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No access token found"])))
            return
        }
        
        // Create request body
        let requestBody = TikTokUploadRequest(
            sourceInfo: .init(
                videoUrl: videoURL,
                source: "PULL_FROM_URL"
            ),
            postInfo: .init(
                privacyLevel: "SELF_ONLY",
                disableComment: true,
                title: "Video uploaded via TikTok API #fyp",
                videoCoverTimestampMs: 1000,
                disableStitch: false,
                disableDuet: false
            )
        )
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Encode request body
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Make request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Handle response
            if let httpResponse = response as? HTTPURLResponse {
                let message = "Status: \(httpResponse.statusCode)"
                DispatchQueue.main.async {
                    if (200...299).contains(httpResponse.statusCode) {
                        completion(.success(message))
                    } else {
                        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "TikTok API error: \(message)"])
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }

    // Add this struct for the creator info response
    struct CreatorInfoResponse: Decodable {
        // Add properties based on the response you expect
        // This is a placeholder structure
        let status: String?
    }

    // Add the query creator info method
    private func queryCreatorInfo(completion: @escaping (Result<CreatorInfoResponse, Error>) -> Void) {
        let creatorInfoURL = "https://open.tiktokapis.com/v2/post/publish/creator_info/query/"
        guard let url = URL(string: creatorInfoURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid creator info URL"])))
            return
        }
        
        // Get access token from UserDefaults
        guard let accessToken = UserDefaults.standard.string(forKey: "TikTokAccessToken") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No access token found"])))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Make request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Handle response
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(CreatorInfoResponse.self, from: data)
                            DispatchQueue.main.async {
                                completion(.success(response))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                    }
                } else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, 
                                      userInfo: [NSLocalizedDescriptionKey: "Creator info API error: Status \(httpResponse.statusCode)"])
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
}

// Response model for S3 URL endpoint
struct S3UploadResponse: Decodable {
    let uploadURL: String
    
    enum CodingKeys: String, CodingKey {
        case uploadURL = "uploadURL"
    }
}
