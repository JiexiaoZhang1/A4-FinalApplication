//  loginViewController.swift
//  SmartTravelApp
//
//  Created by student on 25/5/2024.
//

import UIKit
import Firebase
import FirebaseFirestore

class loginViewController: UIViewController {
    static var myname = "" // Static variable to store the logged-in user's name
    @IBOutlet weak var password: UITextField! // Outlet for the password text field
    @IBOutlet weak var myimage: UIImageView! // Outlet for the user's image view
    @IBOutlet weak var username: UITextField! // Outlet for the username text field
    @IBOutlet weak var loader: UIActivityIndicatorView! // Outlet for the activity indicator view
    var accounts = [Account]() // Array to store account information

    override func viewDidLoad() {
        super.viewDidLoad()
        myimage.layer.cornerRadius  = 20 // Set corner radius for the user's image view
        loader.stopAnimating() // Stop the activity indicator animation
        loader.isHidden = true // Hide the activity indicator
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)) // Add tap gesture recognizer to dismiss keyboard
        view.addGestureRecognizer(tapGesture1) // Add tap gesture recognizer to the view
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        print(accounts.description) // Print the description of the 'accounts' array
        if username.text != "" && password.text != "" { // Check if username and password are not empty
            loader.startAnimating() // Start the activity indicator animation
            loader.isHidden = false // Unhide the activity indicator
            Task {
                do {
                    try await verifyAccount(username: username.text!, password: password.text!) // Call the asynchronous function to verify the account
                } catch {
                    print("Error verifying account: \(error)") // Print error message
                    self.showAlert(title: "Warning", message: "Error verifying account: \(error)") // Show alert with error message
                }
            }
        } else {
            self.showAlert(title: "Warning", message: "No empty username or password") // Show alert for empty username or password
        }
    }

    func verifyAccount(username: String, password: String) {
        let db = Firestore.firestore() // Get a reference to the Firestore database
        
        // Query the 'accounts' collection in Firestore for the given username
        db.collection("accounts").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)") // Print error message
                self.showAlert(title: "Warning", message: "Error getting documents: \(error)") // Show alert with error message
            } else {
                if let document = querySnapshot?.documents.first {
                    let storedPassword = document.get("password") as? String ?? "" // Get the stored password from the document
                    if storedPassword == password {
                        // Username and password match, perform segue to show main screen
                        self.loader.isHidden = true // Hide the activity indicator
                        self.loader.stopAnimating() // Stop the activity indicator animation
                        loginViewController.myname = self.username.text! // Set the logged-in user's name
                        self.performSegue(withIdentifier: "showMain", sender: true) // Perform segue to show the main screen
                    } else {
                        // Password does not match
                        self.loader.stopAnimating() // Stop the activity indicator animation
                        self.loader.isHidden = true // Hide the activity indicator
                        self.showAlert(title: "Warning", message: "Incorrect password") // Show alert for incorrect password
                        print("Incorrect password") // Print message
                    }
                } else {
                    // Username not found
                    self.loader.stopAnimating() // Stop the activity indicator animation
                    self.loader.isHidden = true // Hide the activity indicator
                    self.showAlert(title: "Warning", message: "Username not found") // Show alert for username not found
                    print("Username not found") // Print message
                }
            }
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true) // Dismiss the keyboard
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert) // Create an alert controller
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil) // Create an OK action
        alertController.addAction(okAction) // Add the OK action to the alert controller
        present(alertController, animated: true, completion: nil) // Present the alert controller
    }
    
    @IBAction func backFromLoginMain(_ segue : UIStoryboardSegue) {
        // Action to handle unwind segue from the main screen
    }
}

