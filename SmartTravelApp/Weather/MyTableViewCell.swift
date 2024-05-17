

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet weak var zhuangkuangLabel: UILabel!
    @IBOutlet weak var zuidiwenduLabel: UILabel!
    @IBOutlet weak var zuigaowenduLabel: UILabel!
    @IBOutlet weak var riqiLabel: UILabel!
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
