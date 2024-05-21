import UIKit

class ListEventTableViewCell: UITableViewCell {


    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var bearinglabel: UILabel!
    @IBOutlet weak var distancelabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
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
