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
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        if username.text != "" && password.text != "" {
            // Check if the username is available
            if isUsernameAvailable(username: username.text!) {
                // Store the username and password in UserDefaults
                UserDefaults.standard.set(password.text, forKey: username.text!)
                inserttofirebasedb(username: username.text!, password: password.text!)
                UserDefaults.standard.synchronize()

                // Show a success alert
                let alertController = UIAlertController(title: "Success", message: "Registration successful", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    // Dismiss the current view controller
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            } else {
                // Show a warning alert if the username is already taken
                let alertController = UIAlertController(title: "Warning", message: "Username already exists, please choose another one", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        } else {
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
                    print("Error adding document: \(err)")
                } else {
                    print("Successfully created teams")
                }
            })
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }

        movieCollection.getDocuments() { (result, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // Loop through the documents and print the team information
                for document in result!.documents {
                    let conversionResult = Result {
                        try document.data(as: Account.self)
                    }

                    switch conversionResult {
                    case .success(let movie):
                        print("Team: \(movie)")
                        print("yaya 1")
                    case .failure(let error):
                        print("Error decoding movie: \(error)")
                    }
                }
            }
        }
    }
}
