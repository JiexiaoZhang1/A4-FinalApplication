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
    @IBOutlet weak var myimage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var accounts = [Account]()

    override func viewDidLoad() {
        super.viewDidLoad()
        myimage.layer.cornerRadius  = 20
        DispatchQueue.main.async {
            self.fetchUserData()
        }
       
        loader.stopAnimating()
        loader.isHidden = true
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture1)
   
        
        
    }
    
    func fetchUserData() {
        print("1111")
        let db = Firestore.firestore()
        let movieCollection = db.collection("accounts")
        movieCollection.getDocuments() { (result, err) in
            if let err = err
            {
                print("1111 Error getting documents: \(err)")
            }
            else
            {
                print("1111 Movi22e")
                for document in result!.documents
                {
                    print("11112 Movi22e")
                    let conversionResult = Result
                    {
                      //  print("11111 NANA")
                        try document.data(as: Account.self)
                    }
                    switch conversionResult
                    {
                        case .success(let movie):
                            print("1111 Movie: \(movie)")
                                
                            //NOTE THE ADDITION OF THIS LINE
                            self.accounts.append(movie)
                            
                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("1111 Error decoding movie: \(error)")
                    }
                }
                
              
            }
            
            print("1111211 Movi22e")
        }
    }

    @IBAction func loginTapped(_ sender: Any) {
        print("1111 ",accounts.description)
        if username.text != "" && password.text != "" {
            loader.startAnimating()
            loader.isHidden = false
            Task {
                do {
                    print("1111 User found:")
                    try await verifyAccount(username: username.text!, password: password.text!)
                } catch {
                    print("111 Error verifying account: \(error)")
                }
            }
        } else {
            self.showAlert(title: "Alert", message: "No empty username or password")
        }
    }

    func verifyAccount(username: String, password: String) async throws {
        let db = Firestore.firestore()
       
        let querySnapshot = try await db.collection("accounts").whereField("username", isEqualTo: username).getDocuments()
        for document in querySnapshot.documents {
            // 检查密码等其他逻辑
            print("1111 User found: \(document.documentID) => \(document.data())")
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