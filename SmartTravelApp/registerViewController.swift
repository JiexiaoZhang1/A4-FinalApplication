//
//  registerViewController.swift
//  SmartTravelApp
//
//  Created by student on 25/5/2024.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

// The registerViewController class is responsible for handling user registration
class registerViewController: UIViewController {
    @IBOutlet weak var myimage: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myimage.layer.cornerRadius  = 20
        self.loader.stopAnimating()
        self.loader.isHidden = true
        
        // Add a tap gesture recognizer to dismiss the keyboard when the user taps outside the text fields
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture1)
    }

    // Dismiss the keyboard when the user taps outside the text fields
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Handle the registration process when the user taps the "Register" button
    @IBAction func registerTapped(_ sender: Any) {
        print("11111 dddd")
        loader.startAnimating()
        loader.isHidden = false
        if username.text != "" && password.text != "" {
            // Check if the username is available
          //  if isUsernameAvailable(username: username.text!) {
                // Store the username and password in UserDefaults
              //  UserDefaults.standard.set(password.text, forKey: username.text!)
                
                inserttofirebasedb(username: username.text!, password: password.text!)
               // UserDefaults.standard.synchronize()

            
          /*  } else {
                // Show a warning alert if the username is already taken
                let alertController = UIAlertController(title: "Warning", message: "Username already exists, please choose another one", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }*/
        } else {
            loader.stopAnimating()
            loader.isHidden = true
            // Show a warning alert if the username or password is empty
            let alertController = UIAlertController(title: "Warning", message: "Username and password cannot be empty", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    // Handle the dismissal of the view controller when the user taps the "Dismiss" button
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // Check if the username is available
    func isUsernameAvailable(username: String) -> Bool {
        return UserDefaults.standard.string(forKey: username) == nil
    }

    // Insert the user's information into the Firebase Firestore database
    func inserttofirebasedb(username: String, password: String) {
        let db = Firestore.firestore()
        let movieCollection = db.collection("accounts")
        let matrix = Account(username: username, password: password)

        do {
            try movieCollection.addDocument(from: matrix, completion: { (err) in
                if let err = err {
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                    print("1111 Error adding document: \(err)")
                } else {
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                    print("1111 Successfully created teams")
                }
            })
        } catch let error {
            loader.stopAnimating()
            loader.isHidden = true
            print("1111 Error writing city to Firestore: \(error)")
        }

        movieCollection.getDocuments() { (result, err) in
            if let err = err {
                self.loader.stopAnimating()
                self.loader.isHidden = true
                print("1111 Error getting documents: \(err)")
            } else {
                // Loop through the documents and print the team information
                for document in result!.documents {
                    let conversionResult = Result {
                        try document.data(as: Account.self)
                    }

                    switch conversionResult {
                    case .success(let movie):
                        self.loader.stopAnimating()
                        self.loader.isHidden = true
                        print("1111 Team: \(movie)")
                        print("1111 yaya 1")
                        self.dismiss(animated: true, completion: nil)
                        
                    case .failure(let error):
                        self.loader.stopAnimating()
                        self.loader.isHidden = true
                        print("1111 Error decoding movie: \(error)")
                    }
                }
            }
        }
    }
    
  
}
