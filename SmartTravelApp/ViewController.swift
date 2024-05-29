import UIKit
import SafariServices
import CoreLocation
import AVFoundation
import Foundation

/// A `UIViewController` that manages a collection view displaying a slider of images.
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate {
    
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
    
    
    var myposition:String = "-37.4853,144.5738"
    var timerLoadData = Timer()
    let locationManager = CLLocationManager()
    var weburl:String = ""
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        hasLoadedData = false
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

        self.timerLoadData = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(monitorData), userInfo: nil, repeats: true)
       

        
        self.getCurrentLocationAndLoadData()

        print("Current \(myposition)")
     
    }
    
    func getCurrentLocation(completion: @escaping (String) -> Void) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        locationCompletionHandler = completion
    }

    var a = ""
    private var hasLoadedData = false
    func getCurrentLocationAndLoadData() {
        getCurrentLocation { [weak self] position in
            print("Current position: \(position)")
            
            guard let self = self else { return }

            if self.hasLoadedData {
                return
            }
            
            if self.a == position && !position.isEmpty {
                print("Current position: \(position)")
                self.loaddata(position: position)
                self.hasLoadedData = true
            }
            
            self.a = position
        }
    }
    
    var locationCompletionHandler: ((String) -> Void)?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
       
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        myposition = "\(latitude),\(longitude)"
        
 
        locationManager.stopUpdatingLocation()
        
     
        if let handler = locationCompletionHandler {
            handler(myposition)
        }
    }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error getting location: \(error.localizedDescription)")
            if self.hasLoadedData {
                return
            }
            self.loaddata(position: myposition)
            hasLoadedData = true
        }
    
    
    private var requestCount = 0
    var isFinishImage:Bool = false
    @objc func monitorData() {

        if isFinishLoadInitialData{
            requestCount = location_id.count
            imageurl = Array(repeating: "1", count: location_id.count)
            loadImageURLs()
          
        }
  
        if imageurl.count == name.count && imageurl.count != 0 && name.count != 0
            &&  imageurl.first != "1"
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                [self] in
                theTable.reloadData()
                loader.isHidden = true
                loader.stopAnimating()
                
            }
            timerLoadData.invalidate()
        }else{
           
        }
       
    }
    
    var location_id: [String] = []
    var name: [String] = []
    var distance: [String] = []
    var bearing: [String] = []
    var address_obj: [String] = []
    var imageurl: [String] = []
    var completionCount = 0
    var totalCount = 0
    var isFinishLoadInitialData:Bool = false
    func loaddata(position:String) {
        isFinishLoadInitialData = false
        let url = URL(string: "https://api.content.tripadvisor.com/api/v1/location/nearby_search?latLong=\(position)&key=FC2484B01C6841F7974B9ECDF8967443&category=restaurants&language=en&radiusUnit=600")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server responded with an error")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String: Any] {
                    if let dataArray = dictionary["data"] as? [[String: Any]] {
                        totalCount = dataArray.count
                        for item in dataArray {
                            if let location_id = item["location_id"] as? String,
                               let name = item["name"] as? String,
                               let distance = item["distance"] as? String,
                               let bearing = item["bearing"] as? String,
                               let address_obj = item["address_obj"] as? [String: String],
                               let address_string = address_obj["address_string"] {
                                self.location_id.append(location_id)
                                self.name.append(name)
                                self.distance.append(distance)
                                self.bearing.append(bearing)
                                self.address_obj.append(address_string)
                                //loadImageURL(locationid: location_id)
                            }
                        }
                        isFinishLoadInitialData = true
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
            
            
        }

      
        task.resume()
    }

    func loadImageURLs() {
        
        for (index, locationid) in location_id.enumerated() {
            let urlString = "https://api.content.tripadvisor.com/api/v1/location/\(locationid)/photos?key=FC2484B01C6841F7974B9ECDF8967443&language=en"
            print(urlString)
            print("")

            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                continue
            }

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Server responded with an error")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonDict = json as? [String: Any],
                       let dataArray = jsonDict["data"] as? [[String: Any]],
                       let firstData = dataArray.first,
                       let imagesDict = firstData["images"] as? [String: Any],
                       let originalImageDict = imagesDict["original"] as? [String: Any],
                       let imageURL = originalImageDict["url"] as? String {
                       
                        self.imageurl[index] = imageURL
                       
                    } else {
                    
                        self.imageurl[index] = ""
                        
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
  
                self.isFinishLoadInitialData = false
                //self.theTable.reloadData()
            }

            task.resume()
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
        APIViewController.category = "attractions"
        self.performSegue(withIdentifier: "showapiview", sender: true)
    }

    @IBAction func hotelTapped(_ sender: Any) {
        APIViewController.category = "hotels"
        self.performSegue(withIdentifier: "showapiview", sender: true)
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
        return location_id.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell and cast it to your custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListEventTableViewCell", for: indexPath) as! ListEventTableViewCell

        
        cell.nameLabel.text = "Name: "  + name[indexPath.row]

        if let distanceInMeters = Double(distance[indexPath.row]) {
               var distanceString: String
               if distanceInMeters < 1 {
                   distanceString = String(format: "%.2f m", distanceInMeters * 1000)
               } else {
                   distanceString = String(format: "%.2f m", distanceInMeters)
               }
            cell.distancelabel.text = "Distance: \(distanceString)"
           } else {
               cell.distancelabel.text = "Distance: N/A"
           }
        
        cell.bearinglabel.text = "Bearing: " + bearing[indexPath.row]
        cell.addresslabel.text = address_obj[indexPath.row]
        cell.addresslabel.numberOfLines = 0
       
       loadImageFromURL(urlString: imageurl[indexPath.row]) { (image) in
            if let image = image {
                // Set the image to the UIImageView
                cell.myimage.image = image
                cell.myimage.contentMode = .scaleToFill
               
            } else {
           
                cell.myimage.image = UIImage(named: "noimage")
               
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
        if urlString == "" {
            completion(nil)
            return
        }
        
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

    
    // This method is called when a row in the table view is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Start the activity indicator animation and make it visible
        loader.startAnimating()
        self.loader.isHidden = false
        
        // Call the loaddata function with the appropriate URL
        loaddata(urls: "https://api.content.tripadvisor.com/api/v1/location/\(location_id[indexPath.row])/details?key=FC2484B01C6841F7974B9ECDF8967443")
    }

    // This method fetches data from the specified URL
    func loaddata(urls:String){
        // Create a URL object from the provided string
        guard let url = URL(string: urls) else {
            return
        }

        // Create a data task to fetch the data from the URL
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for any errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // If data is available, parse the JSON response
            if let data = data {
                do {
                    // Convert the data to a JSON object
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    // Check if the JSON object is a dictionary
                    if let dictionary = json as? [String: Any] {
                        // Update the UI on the main thread
                        DispatchQueue.main.async {
                            // Check if the "web_url" key exists in the dictionary
                            if let writeReviewURL = dictionary["web_url"] as? String {
                                print(writeReviewURL)
                                self.weburl = writeReviewURL
                                
                                // Create a URL object from the web_url string
                                guard let url = URL(string: self.weburl) else {
                                    return
                                }
                                
                                // Load the writeReviewURL in the SFSafariViewController
                                let safariVC = SFSafariViewController(url: url)
                                self.present(safariVC, animated: true, completion: {
                                    // Stop the activity indicator animation and hide it
                                    self.loader.stopAnimating()
                                    self.loader.isHidden = true
                                })
                            }
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
        
        // Start the data task
        task.resume()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Get the title of the current row
        let title = name[indexPath.row]
        
        // Retrieve the saved titles from UserDefaults
        let savedTitles = UserDefaults.standard.array(forKey: "SavedTitles") as? [String] ?? []
        
        // Check if the current title is already saved
        let isTitleSaved = savedTitles.contains(title)
        
        // Create a "Favorite" or "Remove" action based on the saved status
        let action = UIContextualAction(style: .destructive, title: isTitleSaved ? "Remove" : "Favorite") { (action, view, completion) in
            // If the title is saved, remove it from the array and save it in UserDefaults
            if isTitleSaved {
                var updatedTitles = savedTitles
                updatedTitles.removeAll(where: { $0 == title })
                UserDefaults.standard.set(updatedTitles, forKey: "SavedTitles")
                
                // Show an alert to indicate successful removal
                let alertController = UIAlertController(title: "Success", message: "The item has been removed successfully.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Add the title to the array and save it in UserDefaults
                var updatedTitles = savedTitles
                updatedTitles.append(title)
                UserDefaults.standard.set(updatedTitles, forKey: "SavedTitles")
                
                // Show an alert to indicate successful save
                let alertController = UIAlertController(title: "Success", message: "The item has been saved successfully.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
            // Indicate that the action was completed successfully
            completion(true)
        }
        
        // Set the background color of the action based on the saved status
        action.backgroundColor = isTitleSaved ? UIColor.systemRed : UIColor.systemYellow
        
        // Set the image of the action based on the saved status
        action.image = isTitleSaved ? UIImage(systemName: "trash") : UIImage(systemName: "star")
        
        // Create a swipe actions configuration with the "Favorite" or "Remove" action
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    
    
    
}

