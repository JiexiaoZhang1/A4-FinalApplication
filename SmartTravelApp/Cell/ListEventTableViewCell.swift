//
//  ListEventTableViewCell.swift
//  SmartTravelApp
//
//  Created by student on 7/5/2024.
//

import UIKit

class ListEventTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptions: UITextView!
    @IBOutlet weak var myimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
