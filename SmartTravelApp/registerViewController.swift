

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
        
        // Set the corner radius of the myimage UIImageView
        myimage.layer.cornerRadius  = 20
        
        // Stop and hide the loader UIActivityIndicatorView
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
        
        // Start animating the loader and make it visible
        loader.startAnimating()
        loader.isHidden = false
        
        // Check if the username and password text fields are not empty
        if username.text != "" && password.text != "" {
            // Check if the length of the password is greater than 6
            if password.text!.count > 6 {
                // Password length meets the requirement, proceed with the registration logic
                inserttofirebasedb(username: username.text!, password: password.text!)
            } else {
                // Password length does not meet the requirement, display a warning message
                let alertController = UIAlertController(title: "Warning", message: "Password should be at least 7 characters long", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                
                // Stop animating the loader and make it hidden
                loader.stopAnimating()
                loader.isHidden = true
            }
        } else {
            // Stop animating the loader and make it hidden
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
        let accountCollection = db.collection("accounts")

        // Check if the username is already registered
        accountCollection.whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                self.loader.stopAnimating()
                self.loader.isHidden = true
                print("Error checking username existence: \(error)")
                self.showAlert(title: "Warning", message: "Error checking username existence: \(error)")
            } else if querySnapshot!.documents.isEmpty {
                // Username is not found, proceed with registration
                let newAccount = Account(username: username, password: password, gender: "Male", imagepath: "")

                do {
                    try accountCollection.addDocument(from: newAccount) { error in
                        if let error = error {
                            // Handle the error
                            print("Error adding document: \(error)")
                            self.loader.stopAnimating()
                            self.loader.isHidden = true
                            self.showAlert(title: "Warning", message: "Error adding document: \(error)")
                        } else {
                            // Registration successful
                            print("Successfully created account")
                            self.loader.stopAnimating()
                            self.loader.isHidden = true
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                } catch {
                    // Handle the error
                    print("Error writing account to Firestore: \(error)")
                    self.showAlert(title: "Warning", message: "Error writing account to Firestore: \(error)")
                }
            } else {
                // Username already exists, show a warning to the user
                self.loader.stopAnimating()
                self.loader.isHidden = true
                self.showAlert(title: "Warning", message: "Username already exists, please choose a different username")
                print("Username already exists, please choose a different username")
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
