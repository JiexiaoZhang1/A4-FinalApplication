import UIKit
import WebKit

class ChatViewController: UIViewController {
    
    // Outlet for the WKWebView
    @IBOutlet weak var myWebView: WKWebView!
    
    // Outlet for the UIActivityIndicatorView
    @IBOutlet weak var loader: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigation delegate of the web view
        myWebView.navigationDelegate = self
    
        // Check if the URL is valid and load it in the web view
        if let url = URL(string: "http://neostempprojects.com") {
            let request = URLRequest(url: url)
            myWebView.load(request)
        }
    }
}

// Extension to handle WKNavigationDelegate methods
extension ChatViewController: WKNavigationDelegate {
    
    // Called when the web view starts loading a page
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Start animating the activity indicator
        loader.startAnimating()
    }
    
    // Called when the web view finishes loading a page
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Stop animating the activity indicator
        loader.stopAnimating()
        // Hide the activity indicator
        loader.isHidden = true
        // Log that the web page has been loaded
        print("Web Page Loaded")
    }
    
    // Called when the web view fails to load a page
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Stop animating the activity indicator
        loader.stopAnimating()
        // Hide the activity indicator
        loader.isHidden = true
        // Log the error message
        print("Failed to load web page: \(error.localizedDescription)")
    }
}
