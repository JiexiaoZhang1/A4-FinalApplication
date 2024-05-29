//
//  loginViewController.swift
//  SmartTravelApp
//
//  Created by student on 25/5/2024.
//

import UIKit
import Firebase
import FirebaseFirestore

class loginViewController: UIViewController {
    static var myname = ""
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!

    @IBOutlet weak var loader: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.stopAnimating()
        loader.isHidden = true
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture1)
        
        
    }

    @IBAction func loginTapped(_ sender: Any) {
        if username.text != "" && password.text != "" {
            loader.startAnimating()
            loader.isHidden = false
            verifyAccount(username: username.text!,password:password.text!)
        }else{
            self.showAlert(title: "Alert", message: "No empty username or password")
        }
      
       
    }

    
    func verifyAccount(username: String, password: String) {
       
        let db = Firestore.firestore()
        let accountsCollection = db.collection("accounts")

        // 查询指定用户名和密码的账号记录
        accountsCollection.whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error verifying account: \(error)")
            } else {
                if !querySnapshot!.isEmpty {
                    // 匹配的记录存在
                    print("Account with username \(username) and password \(password) exists.")
                    loginViewController.myname = username
                    self.performSegue(withIdentifier: "showMain", sender: true)
        
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                    
                } else {
                    // 未找到匹配的记录
                    print("Account with username \(username) and password \(password) does not exist.")
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                    self.showAlert(title: "Alert", message: "Account with username \(username) and password \(password) does not exist.")
                }
            }
        }
    }




    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
