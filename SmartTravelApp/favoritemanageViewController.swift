//
//  favoritemanageViewController.swift
//  SmartTravelApp
//
//  Created by student on 28/5/2024.
//

import UIKit

class favoritemanageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var theTable: UITableView!
    var mystring:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedTitles = UserDefaults.standard.array(forKey: "SavedTitles") as? [String] {
            mystring = savedTitles
        }
        theTable.delegate = self
        theTable.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mystring.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritemanageTableViewCell", for: indexPath) as! favoritemanageTableViewCell
        cell.mylabel.text = mystring[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mystring.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            UserDefaults.standard.set(mystring, forKey: "SavedTitles")
        }
    }
}

