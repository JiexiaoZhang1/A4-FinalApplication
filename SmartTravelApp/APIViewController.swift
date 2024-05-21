//
//  HotelsViewController.swift
//  SmartTravelApp
//
//  Created by student on 22/5/2024.
//

import UIKit
import CoreLocation

class HotelsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var theTable: UITableView!
 
    var timer = Timer()  // Timer used to change images automatically at regular intervals.
    var counter = 0  // Counter to track the current index of displayed image in the slider.
    
    var myposition:String = "-37.9105126,145.1344988"
    var timerLoadData = Timer()
    let locationManager = CLLocationManager()
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        hasLoadedData = false
        loader.startAnimating()
    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 延迟1秒
                [self] in
                theTable.reloadData()
                loader.isHidden = true
                loader.stopAnimating()
                
            }
            timerLoadData.invalidate()
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
    var isFinishLoadInitialData:Bool = false
    func loaddata(position:String) {
        isFinishLoadInitialData = false
        let url = URL(string: "https://api.content.tripadvisor.com/api/v1/location/nearby_search?latLong=\(position)&key=FC2484B01C6841F7974B9ECDF8967443&category=hotels&language=en&radiusUnit=600")!
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
    
  
}

extension HotelsViewController {
    
  
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
           
                cell.myimage.image = UIImage(named: "t1")
               
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

    
    

}