//
//  AddTodoViewController.swift
//  TaskApp
//
//  Created by student on 1/5/2024.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class AddTaskViewController: UIViewController {
    
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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Binding
        setupBindings()
        
        addDatePicker()
        addTimePicker()
        
        // Title Focus
        txtTitle.becomeFirstResponder()
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
    

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        txtTitle.endEditing(true)
        txtDescription.endEditing(true)
        
        print("wegwr",txtTime.text)
        var timetxt = txtTime.text! + ":02"
        let todoObject = Todo(title: txtTitle.text!, date: txtDate.text!, time: timetxt, description: txtDescription.text)
        todoObject.saveToUserDefaults() // 保存到 UserDefaults 中
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHome"), object: nil, userInfo: nil)
       
        showAlert()
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Success", message: "Record data successfully.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 在视图控制器中呈现警报框
        present(alertController, animated: true, completion:{
            self.txtTitle.text = ""
            self.txtDescription.text = ""
            
        })
    }


    

    @objc func donePressed() {
        self.view.endEditing(true)
    }
    

    @objc func trashPressed() {
        txtTime.text = ""
        self.view.endEditing(true)
    }
    
}
