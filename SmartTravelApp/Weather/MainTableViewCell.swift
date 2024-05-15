//
//  MainTableViewCell.swift
//  WeatherProApp
//
//  Created by student on 27/4/2024.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var cityname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
