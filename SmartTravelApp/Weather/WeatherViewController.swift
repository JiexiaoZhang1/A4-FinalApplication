//
//  MainViewController.swift
//  WeatherProApp
//
//  Created by student on 27/4/2024.
//

import UIKit
import CoreData

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var theTable: UITableView!
    var contacts: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self!.fetchData()
                self?.theTable.reloadData()
            }
    }
    
    func fetchData() {
       contacts.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"WeatherTable")
        do {
           contacts = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func newTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "City", message: "Please enter city name", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter city name here"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            if let textField = alertController.textFields?.first, let text = textField.text, !text.isEmpty {
                // Do something with the entered text
                print("Entered text: \(text)")
                self.saveDataToDB(name: text)
                DispatchQueue.main.async { [self] in
                    theTable.reloadData()
                }
                
            } else {
                // Text field is empty
                print("Text field is empty")
            }
        }
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    func saveDataToDB(name:String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let contact = NSEntityDescription.insertNewObject(forEntityName: "WeatherTable", into: managedContext)
        
        contact.setValue(name, forKeyPath: "name")
    
        
        do {
            try managedContext.save()
            DispatchQueue.main.async { [self] in
                self.fetchData()
                theTable.reloadData()
            }
            showsuccessAlert()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func showsuccessAlert(){
        let alertController = UIAlertController(
               title: "Tip",
               message: "The city name inserted successfully.",
               preferredStyle: .alert
           )
           
           let okAction = UIAlertAction(
               title: "OK",
               style: .default,
               handler: { _ in
                   DispatchQueue.main.async { [self] in
                       self.fetchData()
                       theTable.reloadData()
                   }
               }
           )
           
           alertController.addAction(okAction)
           
           present(alertController, animated: true, completion: nil)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else {
            
            return UITableViewCell()
        }
        
        let contact = contacts[indexPath.row]
        if let name = contact.value(forKeyPath: "name") as? String
        {
            cell.cityname.text = name
        }
        
        return cell
    }
    
    @IBAction func editTapped(_ sender: Any) {
        print("edit here...")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
            print("You selected row \(indexPath.row)")
        let contact = contacts[indexPath.row]
        if let name = contact.value(forKeyPath: "name") as? String
        {
            ViewController.location = name
            self.performSegue(withIdentifier: "showDetails", sender: true)
        }
      
        }


}
