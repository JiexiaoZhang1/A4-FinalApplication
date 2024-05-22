import UIKit
import WebKit

class FunctionViewController: UIViewController {
    
    // Static variable to store the web URL
    static var weburl:String = ""
    // Outlet for the WKWebView
    @IBOutlet weak var myWebView: WKWebView!
    var myurl = ""
      var isshow:Bool = false
      var timerLoadData = Timer()
    // Outlet for the UIActivityIndicatorView
    @IBOutlet weak var loader: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigation delegate of the web view
        myWebView.navigationDelegate = self
    
     
        
        self.timerLoadData = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(monitorData), userInfo: nil, repeats: true)
        
    }
    
    @objc func monitorData() {
            print("aiai")
            if myurl != "" && !isshow{
            
                // Check if the URL is valid and load it in the web view
                if let url = URL(string: myurl) {
                    let request = URLRequest(url: url)
                    myWebView.load(request)
                }
            
                isshow = true
                timerLoadData.invalidate()
                print("aiai show")
            }
            
        }
    
    func loaddata(){
        guard let url = URL(string: FunctionViewController.weburl) else {
                   return
               }

               let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                   if let error = error {
                       print("Error: \(error.localizedDescription)")
                       return
                   }

                   if let data = data {
                       do {
                           let json = try JSONSerialization.jsonObject(with: data, options: [])
                           if let dictionary = json as? [String: Any] {
                               DispatchQueue.main.async {
                                   if let writeReviewURL = dictionary["web_url"] as? String {
                                       print(writeReviewURL)
                                       self.myurl = writeReviewURL
                                       // Load the writeReviewURL in the WKWebView
          
                                   }
                               }
                           }
                       } catch {
                           print("Error decoding JSON: \(error.localizedDescription)")
                       }
                   }
               }
               task.resume()
    }
}

// Extension to handle WKNavigationDelegate methods
extension FunctionViewController: WKNavigationDelegate {
    
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
