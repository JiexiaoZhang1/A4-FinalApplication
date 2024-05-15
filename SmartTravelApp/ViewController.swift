import UIKit
import AVFoundation
import Foundation

/// A `UIViewController` that manages a collection view displaying a slider of images.
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var theTable: UITableView!
 
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
    
    var myname:[String] = []
    var myvicinity:[String] = []
    var rating:[String] = []
    var pricelevel:[String] = []
    var useratng:[String] = []
    var photoref:[String] = []
    
    var timerLoadData = Timer()
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        loader.startAnimating()
        // Initialize the array with images named "01", "02", "03". Assumes these images exist in the asset catalog.
        sliderArray = [UIImage(named: "01")!, UIImage(named: "02")!, UIImage(named: "03")!]
        
        // Setup the collection view's delegate and data source.
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.reloadData()
        
        // Register the custom cell for use in creating new cells.
        self.sliderCollectionView.register(UINib(nibName: "SliderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SliderCollectionViewCell")
        showSlider()  // Initialize and start the image slider.
        
        //show restaurant
        self.getAndPrintPlacesInfo()
        
        self.theTable.reloadData()
       
        self.timerLoadData = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(monitorData), userInfo: nil, repeats: true)
        
    }
    
    @objc func monitorData() {
        if myname.count != 0{
            self.theTable.reloadData()
            timerLoadData.invalidate()
        }
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
    @IBAction func attractionsTapped(_ sender: Any) {
        // Set the web URL for attractions
        FunctionViewController.weburl = "https://www.australia.com/en-sg/places.html"
        // Perform segue to show the function view controller
        self.performSegue(withIdentifier: "showFunction", sender: true)
    }

    @IBAction func transportationTapped(_ sender: Any) {
        // Set the web URL for transportation
        FunctionViewController.weburl = "https://www.australia.com/en-sg/facts-and-planning/getting-around.html"
        // Perform segue to show the function view controller
        self.performSegue(withIdentifier: "showFunction", sender: true)
    }

    @IBAction func weatherTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showWeather", sender: true)
    }

    @IBAction func newsTapped(_ sender: Any) {
      
        self.performSegue(withIdentifier: "shownews", sender: true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of items in the data source array
        return myname.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell and cast it to your custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListEventTableViewCell", for: indexPath) as! ListEventTableViewCell

        cell.nameLabel.text = myname[indexPath.row]
        cell.vicinityLabel.text = myvicinity[indexPath.row]
        cell.ratingLabel.text = "Rating:" + rating[indexPath.row]
        cell.userratingtotallabel.text = "User Ratings Total:" + useratng[indexPath.row]
        
        // Create the URL for the image using the photo reference
        var imgString: String = ""
        imgString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=550&photoreference=" + photoref[indexPath.row]  + "&key=AIzaSyDldmLZx54Tx9LVpGHjPSJkfNjp04EmrCU"
        
        // Load the image from the URL asynchronously
        loadImageFromURL(urlString: imgString) { (image) in
            if let image = image {
                // Set the image to the UIImageView
                cell.myimage.image = image
            } else {
                // Handle the case when image loading fails
                print("Failed to load image from URL: \(imgString)")
            }
        }
        
        return cell
    }
    


    /**
        Loads an image from a given URL string asynchronously.

        - Parameters:
            - urlString: The URL string from which to load the image.
            - completion: A closure that is called when the image loading is complete. It takes an optional `UIImage` parameter.

        - Note: If the URL is invalid or the image data cannot be retrieved, the completion closure is called with a `nil` image.

        - Important: This function should be called from the main thread.
    */
    func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            completion(image)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
            task.resume()
        } else {
            completion(nil)
        }
    }

    
    func fetchPlacesData(completion: @escaping (Data?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-35.2809,149.1300&radius=1000&type=restaurant&language=en-us&key=AIzaSyDldmLZx54Tx9LVpGHjPSJkfNjp04EmrCU" // 替换为你的API密钥
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error fetching data: \(error)")
                    completion(nil)
                    return
                }
                completion(data)
            }
            task.resume()
        } else {
            print("Invalid URL")
            completion(nil)
        }
    }
    
    func parseJSON(jsonData: Data) -> [Place]? {
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let jsonDict = json as? [String: Any],
               let results = jsonDict["results"] as? [[String: Any]] {
                var places = [Place]()
                for result in results {
                    if let name = result["name"] as? String,
                       let vicinity = result["vicinity"] as? String,
                       let rating = result["rating"] as? Double,
                       let priceLevel = result["price_level"] as? Int,
                       let userRatingsTotal = result["user_ratings_total"] as? Int {
                        var photoReference: String? // 默认为nil
                        if let photos = result["photos"] as? [[String: Any]],
                           let firstPhoto = photos.first,
                           let reference = firstPhoto["photo_reference"] as? String {
                            photoReference = reference
                        }
                        let place = Place(name: name,
                                          vicinity: vicinity,
                                          rating: rating,
                                          priceLevel: priceLevel,
                                          userRatingsTotal: userRatingsTotal,
                                          photoReference: photoReference)
                        places.append(place)
                    }
                }
                return places
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        return nil
    }

    func getAndPrintPlacesInfo() {
        fetchPlacesData { [self] (data) in
            if let data = data,
               let places = parseJSON(jsonData: data) {
                
                for place in places {
                    myname.append(place.name)
                    myvicinity.append(place.vicinity)
                    rating.append(String(place.rating))
                    pricelevel.append(String(place.rating))
                    useratng.append(String(place.userRatingsTotal))
                    loader.stopAnimating()
                    loader.isHidden = true
                    print("Name: \(place.name)")
                    print("Vicinity: \(place.vicinity)")
                    print("Rating: \(place.rating)")
                    print("Price Level: \(place.priceLevel)")
                    print("User Ratings Total: \(place.userRatingsTotal)")
                    if let photoReference = place.photoReference {
                        print("Photo Reference: \(photoReference)")
                        photoref.append(photoReference)
                    }
                    print("\n")
                }
            }
        }
    }

    
    
    
}

