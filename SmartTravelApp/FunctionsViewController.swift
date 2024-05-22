//
//  FunctionsViewController.swift
//  SmartTravelApp
//
//  Created by student on 22/5/2024.
//

import UIKit
import WebKit

class FunctionViewController: UIViewController, WKNavigationDelegate {
    
    // Static variable to store the web URL
    static var weburl: String = ""
    // Outlet for the WKWebView
    @IBOutlet weak var myWebView: WKWebView!
    // Outlet for the UIActivityIndicatorView
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var myurl = ""
    var isshow:Bool = false
    var timerLoadData = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        myWebView.navigationDelegate = self
        loader.startAnimating()
        
        guard let url = URL(string:FunctionViewController.weburl) else {
            return
        }
      
            let request = URLRequest(url: url)
            self.myWebView.load(request)
            self.loader.stopAnimating()

       
    }
    
    
  
}
