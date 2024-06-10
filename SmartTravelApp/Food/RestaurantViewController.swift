

import Foundation
import UIKit

struct Place {
    let name: String
    let vicinity: String
    let rating: Double
    let priceLevel: Int
    let userRatingsTotal: Int
    let photoReference: String?
}

class RestaurantViewController: UIViewController {
    var myname:[String] = []
    var myvicinity:[String] = []
    var rating:[String] = []
    var pricelevel:[String] = []
    var useratng:[String] = []
    var photoref:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        getAndPrintPlacesInfo()
    }

    func fetchPlacesData(completion: @escaping (Data?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=25.0338,121.5646&radius=1000&type=restaurant&language=zh-TW&key=AIzaSyDldmLZx54Tx9LVpGHjPSJkfNjp04EmrCU" //
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
                        var photoReference: String?
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

    //
    func getAndPrintPlacesInfo() {
        fetchPlacesData { [self] (data) in
            if let data = data,
               let places = parseJSON(jsonData: data) {
                // 
                for place in places {
                    print("Name: \(place.name)")
                    print("Vicinity: \(place.vicinity)")
                    print("Rating: \(place.rating)")
                    print("Price Level: \(place.priceLevel)")
                    print("User Ratings Total: \(place.userRatingsTotal)")
                    if let photoReference = place.photoReference {
                        print("Photo Reference: \(photoReference)")
                    }
                    print("\n")
                }
            }
        }
    }

    

}
