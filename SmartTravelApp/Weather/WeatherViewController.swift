

import UIKit
import Foundation
import CoreLocation

class WeatherViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate  {
  
    @IBOutlet weak var loader: UIActivityIndicatorView!

    let apiKey = "625cc13e337c4fb2a0541153242604"
    let baseUrl = "https://api.weatherapi.com/v1/forecast.json"
    var location = "Australia"
    var days = 7
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var searchweatheInputBox: UITextField!
    
    @IBOutlet weak var fengsulabel: UILabel!
    @IBOutlet weak var fengxianglabel: UILabel!

    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var wenduLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var chengshiLabel: UILabel!
    @IBOutlet weak var siduLabel: UILabel!

    var riqi:[String] = []
    var zuigaowendu:[String] = []
    var zuidiwendu:[String] = []
    var tianqizhuangkuang:[String] = []
    var tianqitubiao:[String] = []
    var sidu:[String] = []
    var fengsu:[String] = []
    @IBOutlet weak var theTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
       /* locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()*/
        loadData()
        self.chengshiLabel.text = location
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture1)
        tapGesture1.cancelsTouchesInView = false
        
      
    }
    
    func loadData(){
        let url = URL(string: "\(baseUrl)?key=\(apiKey)&q=\(location)&days=\(days)")!


        let task = URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    if let current = json?["current"] as? [String: Any] {
                        let temperatureC = current["temp_c"] as? Double
                        let iconData = current["condition"] as? [String: Any]
                        let icon = iconData?["icon"] as? String
                        let windSpeed = current["wind_kph"] as? Double
                        let windDirection = current["wind_dir"] as? String
                        let humidity = current["humidity"] as? Int
                        let condition = current["condition"] as? [String: Any]
                            let conditionText = condition?["text"] as? String
            
                        DispatchQueue.main.async { [self] in
                            self.loader.stopAnimating()
                            self.loader.isHidden = true
                           // self.chengshiLabel.text = "\(location)"
                            self.wenduLabel.text = "\(temperatureC ?? 0)°C"
                            self.fengsulabel.text = "\(windSpeed ?? 0) kph"
                            self.fengxianglabel.text = "\(windDirection ?? "")"
                            self.siduLabel.text = "\(humidity ?? 0)%"
                            self.weatherLabel.text = "\(conditionText ?? "")"
                            if let icon = icon {
                                if let imageUrl = URL(string: "https:\(icon)") {
                                    DispatchQueue.global().async {
                                        if let data = try? Data(contentsOf: imageUrl) {
                                            DispatchQueue.main.async { [self] in
                                                self.weatherImage.image = UIImage(data: data)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                
                        print()
                    }
                    
        
                    if let forecast = json?["forecast"] as? [String: Any],
                        let forecastday = forecast["forecastday"] as? [[String: Any]] {

                        riqi.removeAll()
                           zuigaowendu.removeAll()
                           zuidiwendu.removeAll()
                           tianqizhuangkuang.removeAll()
                           tianqitubiao.removeAll()
                           sidu.removeAll()
                           fengsu.removeAll()
                        
                        for day in forecastday {
                            if let date = day["date"] as? String,
                                let dayData = day["day"] as? [String: Any] {

                                let maxTemp = dayData["maxtemp_c"] as? Double
                                let minTemp = dayData["mintemp_c"] as? Double
                                let condition = dayData["condition"] as? [String: Any]
                                let text = condition?["text"] as? String
                                let icon = condition?["icon"] as? String
                                let humidity = dayData["avghumidity"] as? Int
                                let windSpeed = dayData["maxwind_kph"] as? Double
                                let windDirection = dayData["wind_dir"] as? String

                                riqi.append("\(date)")
                                zuigaowendu.append("\(maxTemp ?? 0)°C")
                                zuidiwendu.append("\(minTemp ?? 0)°C")
                                tianqizhuangkuang.append("\(text ?? "")")
                                tianqitubiao.append("\(icon ?? "")")
                                sidu.append("\(humidity ?? 0)%")
                                fengsu.append("\(windSpeed ?? 0) kph")
                                DispatchQueue.main.async { [self] in
                                    theTable.reloadData()
                                }
                                print()
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }

        task.resume()
    }
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return riqi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as? MyTableViewCell else {
            return UITableViewCell()
        }
        
       
        cell.riqiLabel.text = riqi[indexPath.row]
        cell.zuigaowenduLabel.text = "Highest Temp：\(zuigaowendu[indexPath.row])"
        cell.zuidiwenduLabel.text = "Lowest Temp：\(zuidiwendu[indexPath.row])"
        cell.zhuangkuangLabel.text = "Condition：\(tianqizhuangkuang[indexPath.row])"
        cell.backgroundColor = UIColor.clear
       
        
        
        if let imageUrl = URL(string: "https:\(tianqitubiao[indexPath.row])") {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let error = error {
                    print("\(error)")
                    return
                }
                
                if let data = data {
                    DispatchQueue.main.async { [weak cell] in
                        cell?.myimage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        
        return cell
    }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard var location = locations.first else { return }
                
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    if let error = error {
                        print("Reverse geocoding failed with error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let placemark = placemarks?.first else {
                        print("No placemark found")
                        return
                    }
                    
                    if let city = placemark.locality {
                        print("Current city: \(city)")
     
                        self.chengshiLabel.text = "\(city)"
                    } else {
                        self.chengshiLabel.text = "--"
                        print("Unable to determine current city")
                    }
                }
                
            
            
            var latitude = location.coordinate.latitude
            var longitude = location.coordinate.longitude
            
            self.location = "\(latitude),\(longitude)"
            riqi.removeAll()
               zuigaowendu.removeAll()
               zuidiwendu.removeAll()
               tianqizhuangkuang.removeAll()
               tianqitubiao.removeAll()
               sidu.removeAll()
               fengsu.removeAll()
            loadData()
            DispatchQueue.main.async { [self] in
                theTable.reloadData()
            }
           
            locationManager.stopUpdatingLocation()
        }
        

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("\(error.localizedDescription)")
            
          
        }
        
    @IBAction func searchTapped(_ sender: Any) {
            if self.searchweatheInputBox.text != "" {
                location  = searchweatheInputBox.text!
                riqi.removeAll()
                   zuigaowendu.removeAll()
                   zuidiwendu.removeAll()
                   tianqizhuangkuang.removeAll()
                   tianqitubiao.removeAll()
                   sidu.removeAll()
                   fengsu.removeAll()
                loadData()
                DispatchQueue.main.async { [self] in
                    theTable.reloadData()
                }
                self.chengshiLabel.text = searchweatheInputBox.text!
            } else {
            
                let alertController = UIAlertController(title: "Tip", message: "Input city name", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
  
}

