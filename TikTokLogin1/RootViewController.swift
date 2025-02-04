import UIKit
import WebKit

class RootViewController: UIViewController {
    private var loginButton: UIButton!
    private var profileImageView: UIImageView!
    private var unionIdLabel: UILabel!
    private var displayNameLabel: UILabel!
    private var logoutButton: UIButton!
    private var postButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign In"
        self.view.backgroundColor = .white
        setupLoginButton()
        setupProfileViews()
        setupLogoutButton()
        setupPostButton()
        
        // Check if TikTok user profile and access token exist
        if let userProfile = UserDefaults.standard.dictionary(forKey: "TikTokUserProfile"),
           let _ = UserDefaults.standard.string(forKey: "TikTokAccessToken") {
            updateUI(with: userProfile)  // Show user profile, logout, and post-reel buttons
        } else {
            showLoginButton() // Show only login button
        }
    }
    
    private func showLoginButton() {
        loginButton.isHidden = false
        profileImageView.isHidden = true
        unionIdLabel.isHidden = true
        displayNameLabel.isHidden = true
        logoutButton.isHidden = true
        postButton.isHidden = true
    }
    
    private func setupProfileViews() {
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isHidden = true
        view.addSubview(profileImageView)
        
        unionIdLabel = UILabel()
        unionIdLabel.translatesAutoresizingMaskIntoConstraints = false
        unionIdLabel.isHidden = true
        view.addSubview(unionIdLabel)
        
        displayNameLabel = UILabel()
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.isHidden = true
        view.addSubview(displayNameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            unionIdLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unionIdLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            
            displayNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            displayNameLabel.topAnchor.constraint(equalTo: unionIdLabel.bottomAnchor, constant: 10)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        // Set border and rounded corners
        logoutButton.layer.borderWidth = 2
        logoutButton.layer.borderColor = UIColor.black.cgColor
        logoutButton.layer.cornerRadius = 10
        
        // Add padding
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.isHidden = true
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupPostButton() {
        postButton = UIButton(type: .system)
        postButton.setTitle("Post Reel", for: .normal)
        postButton.setTitleColor(.black, for: .normal)
        postButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        postButton.addTarget(self, action: #selector(postReel), for: .touchUpInside)
        
        // Set border and rounded corners
        postButton.layer.borderWidth = 2
        postButton.layer.borderColor = UIColor.black.cgColor
        postButton.layer.cornerRadius = 10
        
        // Add padding
        postButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.isHidden = true
        view.addSubview(postButton)
        
        NSLayoutConstraint.activate([
            postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            postButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 15), // Spacing of 15
            postButton.widthAnchor.constraint(equalTo: logoutButton.widthAnchor),
            postButton.heightAnchor.constraint(equalTo: logoutButton.heightAnchor)
        ])
        
    }
    
    @objc private func postReel() {
        print("Post Reel button tapped!") // Replace with your actual functionality
        let postVC = PostViewController()
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    @objc private func logout() {
        UserDefaults.standard.removeObject(forKey: "TikTokAccessToken")
        UserDefaults.standard.removeObject(forKey: "TikTokUserProfile")
        profileImageView.isHidden = true
        unionIdLabel.isHidden = true
        displayNameLabel.isHidden = true
        logoutButton.isHidden = true
        loginButton.isHidden = false
        postButton.isHidden = true
        
        // Clear WebView cache and cookies
        let websiteDataTypes = Set([WKWebsiteDataTypeCookies, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeSessionStorage])
        let dateFrom = Date(timeIntervalSince1970: 0)

        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
            print("Cleared OAuth session data")
        }
    }
    
    func updateUI(with userData: [String: Any]) {
        DispatchQueue.main.async {
            self.loginButton.isHidden = true
            if let avatarURL = userData["avatar_url"] as? String, let url = URL(string: avatarURL) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: data)
                            self.profileImageView.isHidden = false
                        }
                    }
                }
            }
            self.unionIdLabel.text = "ID: \(userData["open_id"] as? String ?? "N/A")"
            self.unionIdLabel.isHidden = true
            
            self.displayNameLabel.text = "Name: \(userData["display_name"] as? String ?? "N/A")"
            self.displayNameLabel.isHidden = false
            
            self.logoutButton.isHidden = false
            self.postButton.isHidden = false
        }
    }
    
    private func setupLoginButton() {
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Login with TikTok", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginButton.addTarget(self, action: #selector(loginWithTikTok), for: .touchUpInside)
        
        // Set border and rounded corners
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.black.cgColor
        loginButton.layer.cornerRadius = 10
        
        // Add padding
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 50)
        
        // Add TikTok icon
        let tiktokIcon = UIImageView(image: UIImage(systemName: "play.fill")) // Replace with actual TikTok logo
        tiktokIcon.tintColor = .black
        tiktokIcon.contentMode = .scaleAspectFit
        tiktokIcon.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addSubview(tiktokIcon)
        
        // Position icon to the right inside the button
        NSLayoutConstraint.activate([
            tiktokIcon.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            tiktokIcon.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -15),
            tiktokIcon.widthAnchor.constraint(equalToConstant: 20),
            tiktokIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Add button to the view
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        // Center button
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 250),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loginWithTikTok() {
        
        let url = URL(string: "https://8e04-69-212-112-109.ngrok-free.app/auth/tiktok")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error fetching auth URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let authURLString = json["authUrl"] as? String {
                            DispatchQueue.main.async {
                                let webViewController = OAuthWebViewController(url: URL(string: authURLString)!, viewController: self)
                                self.present(webViewController, animated: true, completion: nil)
                            }
                        }
                    } catch {
                        print("JSON parsing error: \(error.localizedDescription)")
                    }
                }
                
                task.resume()
    }
}

class OAuthWebViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var authURL: URL
    private var viewController: RootViewController
    
    init(url: URL, viewController: RootViewController) {
        self.authURL = url
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        webView.load(URLRequest(url: authURL))
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.hasPrefix("https://8e04-69-212-112-109.ngrok-free.app/auth/tiktok/callback") {
            if let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value {
                fetchAccessToken(with: code)
//                print("Authorization Code: \(code)")
//                dismiss(animated: true, completion: nil)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func fetchUserProfile(with accessToken: String) {
        let url = URL(string: "https://open.tiktokapis.com/v2/user/info/?fields=open_id,union_id,avatar_url,display_name")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching user profile: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let userData = json["data"] as? [String: Any] {
                    DispatchQueue.main.async {
                        // save user_profile to user defaults
                        UserDefaults.standard.set(userData["user"], forKey: "TikTokUserProfile")
                        UserDefaults.standard.synchronize()
                        
                        
                        self.viewController.updateUI(with: userData["user"] as! [String : Any])
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func fetchAccessToken(with code: String) {
        let url = URL(string: "https://8e04-69-212-112-109.ngrok-free.app/auth/tiktok/callback?code=\(code)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching access token: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let accessToken = json["access_token"] as! String
                    
                    // save access token to user defaults
                    UserDefaults.standard.set(accessToken, forKey: "TikTokAccessToken")
                    UserDefaults.standard.synchronize()
                    
                    self.fetchUserProfile(with: accessToken)
                    
                    // fetch user infow
//                    {
//                      "data": {
//                        "user": {
//                          "avatar_url": "https://p19-sign.tiktokcdn-us.com/tos-useast5-avt-0068-tx/d393eaab5a9edaa77e2a7c95e0efb278~c5_168x168.jpeg?lk3s=a5d48078\u0026nonce=94734\u0026refresh_token=c399794079bcd0c4c22773d34ea6330d\u0026x-expires=1738854000\u0026x-signature=cHVVtNeA6A2vroLiWLn8tW9dank%3D\u0026shp=a5d48078\u0026shcp=8aecc5ac",
//                          "display_name": "Devin Pigera",
//                          "open_id": "-000hvmrYYhL8Cu03rKddA8rUBJAFCCFIuNw",
//                          "union_id": "fe2d71ce-7b93-51ff-9bc4-bafe6a836a0d"
//                        }
//                      },
//                      "error": {
//                        "code": "ok",
//                        "message": "",
//                        "log_id": "20250204154510E36A6DB2990C3D8E8E96"
//                      }
//                    }
                    
                    

                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
