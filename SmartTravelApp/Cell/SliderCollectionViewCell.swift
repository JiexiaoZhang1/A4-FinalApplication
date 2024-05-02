import UIKit

// Defines a custom UICollectionViewCell subclass for displaying images in a slider.
class SliderCollectionViewCell: UICollectionViewCell {
    
    // Connects an UIImageView from the storyboard that displays the image within the cell.
    @IBOutlet weak var sliderImage: UIImageView!
    
    // Called when the cell has been loaded from the storyboard, setting up initial state.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Perform any custom initialization, typically additional setup after loading the view.
    }
}
