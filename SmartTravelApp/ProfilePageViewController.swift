//
//  ProfilePageViewController.swift
//  SmartTravelApp
//
//  Created by student on 10/6/2024.
//

import UIKit

class ProfilePageViewController: UIViewController {
    
    
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var myimage: UIImageView!
    var fileName: String? {
            didSet {
                saveToUserDefaults()
            }
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentFileName = getFileName()
        if let fileName = currentFileName {
     
            print("Current file name: \(fileName)")
            myimage.image =  loadImageFromPath(filename: fileName)
        } else {
            print("No file name saved")
            myimage.image =  UIImage(systemName: "person.fill")
        }
        
        username.text = loginViewController.myname
        
        
        let savedGender = UserDefaults.standard.integer(forKey: "gender")
              gender.selectedSegmentIndex = savedGender
     
    }
    
    @IBAction func genderValueChanged(_ sender: UISegmentedControl) {
       
           let selectedIndex = sender.selectedSegmentIndex

           UserDefaults.standard.set(selectedIndex, forKey: "gender")
    }
    
    func loadImageFromPath(filename: String) -> UIImage {
       
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return UIImage(systemName: "person.fill")!
        }


        let filePath = documentsURL.appendingPathComponent(filename).path

        if fileManager.fileExists(atPath: filePath) {
            if let image = UIImage(contentsOfFile: filePath) {

                return image
            } else {

            }
        } else {

            if let defaultImage = UIImage(named: filename) {
                return defaultImage
            } else {
  
            }
        }
        
        return UIImage(systemName: "photo.artframe")!
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alert = UIAlertController(title: "Select picture source", message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        alert.addAction(photoLibraryAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            alert.addAction(cameraAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
      
        fileName = UUID().uuidString
        saveToUserDefaults()
      
    }
    
    func getFileName() -> String? {
           return UserDefaults.standard.string(forKey: userDefaultsKey)
       }
    
    let userDefaultsKey = "fileName"

    func saveToUserDefaults() {
        
        if let fileName = fileName {
            UserDefaults.standard.set(fileName, forKey: userDefaultsKey)
        } else {

            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
    
    
   

}

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            myimage.image = selectedImage
        }
        
        if let imageUrl = info[.imageURL] as? URL {
          
        } else if let referenceUrl = info[.referenceURL] as? URL {

        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}
