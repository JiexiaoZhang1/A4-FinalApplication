import UIKit
import CoreLocation
import SafariServices

class APIViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var theTable: UITableView!
    static var category:String = ""
    var timer = Timer()  // Timer used to change images automatically at regular intervals.
    var counter = 0  // Counter to track the current index of displayed image in the slider.
    
    var myposition:String = "-37.4853,144.5738"
    var timerLoadData = Timer()
    let locationManager = CLLocationManager()
    var checknetwork = Timer()
    var timerLoadData1 = Timer()
    var responsecounter = 0
    
    var refreshControl: UIRefreshControl!
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if APIViewController.category == "hotels"{
            self.title = "Hotels"
        }else if  APIViewController.category == "attractions"{
            self.title = "Attractions"
        }else{
            self.title = "Restaurant"
        }
        
        hasLoadedData = false
        loader.startAnimating()
    
        self.timerLoadData = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(monitorData), userInfo: nil, repeats: true)
        self.checknetwork = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checknetworkloader), userInfo: nil, repeats: true)
        self.getCurrentLocationAndLoadData()

        print("Current \(myposition)")
     
               refreshControl = UIRefreshControl()
               refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
               theTable.refreshControl = refreshControl
      
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
       print("refresh")
        loader.startAnimating()
        loader.isHidden = false
        hasLoadedData = false
        self.timerLoadData = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(monitorData), userInfo: nil, repeats: true)
        self.checknetwork = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checknetworkloader), userInfo: nil, repeats: true)
        responsecounter = 0
        self.getCurrentLocationAndLoadData()
       
        refreshControl.endRefreshing()
              // theTable.reloadData()
    }
    
    @objc func checknetworkloader() {
        responsecounter += 1
 
        if responsecounter == 10{
            loader.stopAnimating()
            loader.isHidden = true
            checknetwork.invalidate()
            responsecounter = 0
            timerLoadData.invalidate()
        }
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
    
    @IBAction func searchTapped(_ sender: Any) {
        loader.startAnimating()
        loader.isHidden = false
        isFinishLoadInitialData = false
        requestCount = 0
        counter = 0
        hasLoadedData = false
        isFinishImage = false
        
        
        if self.searchinputfield.text != ""{
            self.timerLoadData1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(monitorsearchData), userInfo: nil, repeats: true)
            self.location_id.removeAll()
            self.name.removeAll()
            self.distance.removeAll()
            self.bearing.removeAll()
            self.address_obj.removeAll()
            self.imageurl.removeAll()
            loadsearchdata(keyword: self.searchinputfield.text!)
        }else{
    
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
        print("1111")
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
            self.checknetwork.invalidate()
        }else{
            //print("not")
        }
       
    }
    
    @objc func monitorsearchData() {
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
            timerLoadData1.invalidate()
        }else{
            //print("not")
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
    @IBOutlet weak var searchinputfield: UITextField!
    var isFinishLoadInitialData:Bool = false
    func loaddata(position:String) {

        isFinishLoadInitialData = false
        self.location_id.removeAll()
        self.name.removeAll()
        self.distance.removeAll()
        self.bearing.removeAll()
        self.address_obj.removeAll()
        self.imageurl.removeAll()
        completionCount = 0
        totalCount = 0
        isFinishLoadInitialData = false
        let url = URL(string: "https://api.content.tripadvisor.com/api/v1/location/nearby_search?latLong=\(position)&key=FC2484B01C6841F7974B9ECDF8967443&category=\(APIViewController.category)&language=en&radiusUnit=600")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                loader.stopAnimating()
                loader.isHidden = true
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server responded with an error")
                loader.stopAnimating()
                loader.isHidden = true
                return
            }

            guard let data = data else {
                print("No data received")
                loader.stopAnimating()
                loader.isHidden = true
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
    
    
    func loadsearchdata(keyword:String) {
       
        isFinishLoadInitialData = false
        let url = URL(string: "https://api.content.tripadvisor.com/api/v1/location/search?searchQuery=\(keyword)&key=FC2484B01C6841F7974B9ECDF8967443&category=\(APIViewController.category)&language=en")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                loader.stopAnimating()
                loader.isHidden = true
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server responded with an error")
                loader.stopAnimating()
                loader.isHidden = true
                return
            }

            guard let data = data else {
           
                loader.stopAnimating()
                loader.isHidden = true
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
                               
            
                               let address_obj = item["address_obj"] as? [String: String],
                               let address_string = address_obj["address_string"] {
                                
                          
                                self.location_id.append(location_id)
                                self.name.append(name)
                                self.distance.append("N/A")
                                self.bearing.append("N/A")
                                self.address_obj.append(address_string)
                                //loadImageURL(locationid: location_id)
                      
                            }
                        }
                        isFinishLoadInitialData = true

                       // print("done done....")
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
    
    var weburl:String = ""
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

       /* loader.startAnimating()
        self.loader.isHidden = false
        loaddata(urls: "https://api.content.tripadvisor.com/api/v1/location/\(location_id[indexPath.row])/details?key=FC2484B01C6841F7974B9ECDF8967443")*/
        DetailViewController.myimage = imageurl[indexPath.row]
        DetailViewController.mylocationid = location_id[indexPath.row]
        self.performSegue(withIdentifier: "showWeb2", sender: true)
    }
   
    func loaddata(urls:String){
        guard let url = URL(string: urls) else {
                   return
               }

               let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                   if let error = error {
                       print("Error: \(error.localizedDescription)")
                       return
                   }

                   if let data = data {
                       do {
                           let json = try JSONSerialization.jsonObject(with: data, options: [])
                           if let dictionary = json as? [String: Any] {
                               DispatchQueue.main.async {
                                   if let writeReviewURL = dictionary["web_url"] as? String {
                                       print(writeReviewURL)
                                       self.weburl = writeReviewURL
                                       guard let url = URL(string: self.weburl) else {
                                                  return
                                              }
                                       // Load the writeReviewURL in the WKWebView
                                       let safariVC = SFSafariViewController(url: url)
                                       self.present(safariVC, animated: true, completion: {
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
               task.resume()
    }
    
  
}

extension APIViewController {
    
  
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

        cell.selectionStyle = .none
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
