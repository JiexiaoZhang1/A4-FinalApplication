import UIKit
import AVFoundation
import Foundation

/// A `UIViewController` that manages a collection view displaying a slider of images.
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var timer = Timer()  // Timer used to change images automatically at regular intervals.
    var counter = 0  // Counter to track the current index of displayed image in the slider.
    
    @IBOutlet weak var guestNameLabel: UILabel!  // Label displaying the name of the guest.
    static var name = "Guest"  // Static property to hold the guest's name, defaulting to "Guest".
    @IBOutlet weak var helloLebel: UILabel!  // Label for displaying greeting messages.
    @IBOutlet weak var dayLabel: UILabel!  // Label for displaying the current day.
    
    var sliderArray: [UIImage] = []  // Array holding the images to be displayed in the slider.
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!  // Collection view used for displaying the slider of images.
    @IBOutlet weak var pageView: UIPageControl!  // Page control indicating the current page of the slider.
    
    var registerUsername: String = ""  // Variable to store the registered username.
    var registerPassword: String = ""  // Variable to store the registered password.
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the array with images named "01", "02", "03". Assumes these images exist in the asset catalog.
        sliderArray = [UIImage(named: "01")!, UIImage(named: "02")!, UIImage(named: "03")!]
        
        // Setup the collection view's delegate and data source.
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.reloadData()
        
        // Register the custom cell for use in creating new cells.
        self.sliderCollectionView.register(UINib(nibName: "SliderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SliderCollectionViewCell")
        showSlider()  // Initialize and start the image slider.
    }

    /// Initializes and configures the slider functionality.
    func showSlider() {
        pageView.numberOfPages = sliderArray.count  // Set the number of pages in the page control.
        pageView.currentPage = 0  // Set the initial page.
        
        // Configure and start the timer to change images every 3 seconds.
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
    }
    
    /// Changes the currently displayed image in the slider.
    @objc func changeImage() {
        if counter < sliderArray.count {
            let index = IndexPath(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            pageView.currentPage = counter
            counter = 1
        }
    }
    
    /// Returns the number of items in the section of the collection view.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sliderArray.count
    }
    
    /// Asks the delegate for a cell to insert in a particular location of the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCollectionViewCell", for: indexPath) as? SliderCollectionViewCell
        
        if let vc = cell!.viewWithTag(111) as? UIImageView {
            let img = sliderArray[indexPath.row]
            cell?.sliderImage.image = img
            cell?.sliderImage.contentMode = .scaleAspectFill
            cell?.sliderImage.layer.cornerRadius = 15
        }
        return cell!
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    /// Specifies the margins to apply to content in the specified section of the collection view.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    /// Asks the delegate for the size of the specified item’s cell.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    /// Returns the spacing between successive rows or columns of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    /// Returns the minimum spacing to use between items in the same row or column.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    /// Called just before the view controller’s view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

