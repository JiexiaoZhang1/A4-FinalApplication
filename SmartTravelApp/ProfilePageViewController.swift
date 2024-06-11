
import UIKit
import Firebase

class ProfilePageViewController: UIViewController {
    
    
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var myimage: UIImageView!
    var fileName: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getUserInfo(username: loginViewController.myname)
 
        username.text = loginViewController.myname
        
    
     
    }
    
    func getUserInfo(username: String) {
        let db = Firestore.firestore()
        
        db.collection("accounts").whereField("username", isEqualTo: username).getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let document = querySnapshot?.documents.first {
                    let imagepath = document.get("imagepath") as? String ?? ""
                    let genderstring = document.get("gender") as? String ?? ""
                    
                    // Print or use the retrieved values as needed
                    print("User Info - Image Path: \(imagepath), Gender: \(gender)")
                    if imagepath == ""{
                        myimage.image =  UIImage(systemName: "person.fill")
                    }else{
                        myimage.image =  self.loadImageFromPath(filename: imagepath)
                    }
                    
                    if genderstring == "Male"{
                        gender.selectedSegmentIndex = 0
                    }else
                    {
                        gender.selectedSegmentIndex = 1
                    }
                        
                } else {
                    // Username not found
                    print("Username not found")
                }
            }
        }
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
        
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
      
        fileName = UUID().uuidString
        var genderinfo = "Male"
        if gender.selectedSegmentIndex == 0 {
            genderinfo = "Male"
        }else{
            genderinfo = "FeMale"
        }
        saveImageToDatabase()
        updateUserInfo(username: loginViewController.myname, newGender: genderinfo, newImagePath: fileName)
        
      
    }
    
    func updateUserInfo(username: String, newGender: String, newImagePath: String) {
        let db = Firestore.firestore()
    
        db.collection("accounts").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                self.showAlert(title: "Warning", message:"Error getting documents: \(error)")
            } else {
                if let document = querySnapshot?.documents.first {
                  
                    db.collection("accounts").document(document.documentID).updateData([
                        "gender": newGender,
                        "imagepath": newImagePath
                    ]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                            self.showAlert(title: "Warning", message:"Error updating document: \(error)")
                            
                        } else {
                            print("Document successfully updated")
                            self.showAlert(title: "Warning", message:"User info successfully updated")
                        }
                    }
                } else {
            
                    print("Username not found")
                    self.showAlert(title: "Warning", message: "Username not found")
                }
            }
        }
    }
    
    func saveImageToDatabase(){
       
        guard let selectedImage = myimage.image else {
            return
        }

        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        guard let imageData = selectedImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        do {
            try imageData.write(to: fileURL)

            
        } catch {
            print("error：\(error.localizedDescription)")
        }
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
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
