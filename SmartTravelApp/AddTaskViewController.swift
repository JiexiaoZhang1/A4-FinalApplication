import UIKit
import Foundation
import RxSwift
import RxCocoa

/**
 A view controller used for adding and editing tasks.
 */
class AddTaskViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var txtfavoriterestaurant: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var viewTaskDetails: UIStackView!
    
    // MARK: - Instance Properties
    static let storyboardID = "addTask"
    
    let scheduled = 0, anytime = 1
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()

    var editTask: Todo?
    var indexPath: IndexPath?
    var currentDate: Date?
    
    var disposeBag = DisposeBag()
    var selctedFavoriteditem:String = ""
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Binding
        setupBindings()
        
        addDatePicker()
        addTimePicker()
        
        // Title Focus
        txtTitle.becomeFirstResponder()
       // txtfavoriterestaurant.isEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            txtfavoriterestaurant.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture() {
        // Get the stored data from UserDefaults
        let savedTitles = UserDefaults.standard.array(forKey: "SavedTitles") as? [String] ?? []
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Favorited Restaurant", message: nil, preferredStyle: .alert)
        
        // Add each title as an action to the alert controller
        for title in savedTitles {
            let action = UIAlertAction(title: title, style: .default) { [self] _ in
                // Update the text field with the selected title
                self.txtfavoriterestaurant.text = title
                selctedFavoriteditem = title
            }
            alertController.addAction(action)
        }
        
        // Add a cancel action to the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        guard let task = editTask else {
            self.title = "New Schedule"
            datePicker.date = currentDate ?? Date()
            datePicker.sendActions(for: .valueChanged)
            btnSave.isEnabled = false
            return
        }
        
        self.title = "Edit Schedule"
        btnSave.isEnabled = true
        
        txtTitle.text = task.title
        txtDescription.text = task.description
        if let date = task.date, let pickerDate = date.toDate() {
            datePicker.date = pickerDate
            datePicker.sendActions(for: .valueChanged)
        }
        if let time = task.time, let pickerTime = time.toTime() {
            timePicker.date = pickerTime
            timePicker.sendActions(for: .valueChanged)
        } else {
            txtTime.text = ""
        }
    }
    
    // MARK: - UI Binding
    
    /**
     Sets up the bindings between the UI elements and their corresponding variables.
     */
    func setupBindings() {
        txtTitle.rx.text.asDriver()
            .map {
                guard let title = $0, !title.isEmpty else { return false }
                return true
            }
            .drive(btnSave.rx.isEnabled)
            .disposed(by: disposeBag)
        
        datePicker.rx.date.asDriver()
            .map { $0.toString() }
            .drive(txtDate.rx.text)
            .disposed(by: disposeBag)
        
        timePicker.rx.date.asDriver()
            .map { $0.toTimeString() }
            .drive(txtTime.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - DatePicker
    
    /**
     Adds a date picker to the date text field.
     */
    func addDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnSpace, btnDone], animated: true)
        
        txtDate.inputView = datePicker
        txtDate.inputAccessoryView = toolbar
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
    }
    
    /**
     Adds a time picker to the time text field.
     */
    func addTimePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnTrash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashPressed))
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnTrash, btnSpace, btnDone], animated: true)
        
        txtTime.inputView = timePicker
        txtTime.inputAccessoryView = toolbar
        
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        
    }

    
    // MARK: - Actions
    
    /**
     Called when the save button is pressed.
     - Parameter sender: The save button.
     */
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        txtTitle.endEditing(true)
        txtDescription.endEditing(true)
        
       // var timetxt = txtTime.text! + ":02"
        var timetxt = txtTime.text! + ":02"

        // remove AM/PM string
        timetxt = timetxt.replacingOccurrences(of: "\\b(?:AM|PM)\\b", with: "", options: .regularExpression)

        // remove space
        timetxt = timetxt.replacingOccurrences(of: "\\s+(\\d{2}(:\\d{2})?)$", with: "$1", options: .regularExpression)

        print(timetxt)
        if self.txtfavoriterestaurant.text != ""{
            txtDescription.text = txtDescription.text! + "[\(selctedFavoriteditem)]"
        }
      
        let todoObject = Todo(title: txtTitle.text!, date: txtDate.text!, time: timetxt, description: txtDescription.text)
        todoObject.saveToUserDefaults()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHome"), object: nil, userInfo: nil)
       
        showAlert()
    }
    
    /**
     Displays a success alert after saving the task.
     */
    func showAlert() {
        let alertController = UIAlertController(title: "Success", message: "Record data successfully.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion:{
            self.txtTitle.text = ""
            self.txtDescription.text = ""
        })
    }

    /**
     Called when the done button is pressed on the input accessory view.
     */
    @objc func donePressed() {
        self.view.endEditing(true)
    }

    /**
     Called when the trash button is pressed on the input accessory view.
     */
    @objc func trashPressed() {
        txtTime.text = ""
        self.view.endEditing(true)
    }
}
