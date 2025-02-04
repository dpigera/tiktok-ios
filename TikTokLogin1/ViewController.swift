import UIKit
import WebKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
    }
    
    private func setupLoginButton() {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login with TikTok", for: .normal)
        loginButton.addTarget(self, action: #selector(loginWithTikTok), for: .touchUpInside)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func loginWithTikTok() {
        
        let url = URL(string: "https://8a02-69-212-112-109.ngrok-free.app/auth/tiktok")!
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
                                let webViewController = OAuthWebViewController(url: URL(string: authURLString)!)
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
    
    init(url: URL) {
        self.authURL = url
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
        if let url = navigationAction.request.url, url.absoluteString.hasPrefix("https://8a02-69-212-112-109.ngrok-free.app/auth/tiktok/callback") {
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
    
    private func fetchAccessToken(with code: String) {
        let url = URL(string: "https://8a02-69-212-112-109.ngrok-free.app/auth/tiktok/callback?code=\(code)")!
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
                    
                    
                    if let data = json["data"] as? [String: Any],
                       let user = data["user"] as? [String: Any],
                       let unionId = user["union_id"] as? String {
                        print("Union ID: \(unionId)")
                    } else {
                        print("Union ID not found")
                    }

                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
