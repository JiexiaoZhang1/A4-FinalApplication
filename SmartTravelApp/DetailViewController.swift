

import UIKit
import SafariServices

class DetailViewController: UIViewController {
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var opentime: UITextView!
    @IBOutlet weak var phonelabel: UILabel!
    @IBOutlet weak var pricelevel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var myimage: UIImageView!
    static var mylocationid = ""
    static var myimage = ""
    var myurl = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
        fetchData()
    }

    func fetchData() {
        guard let url = URL(string: "https://api.content.tripadvisor.com/api/v1/location/\(DetailViewController.mylocationid)/details?key=FC2484B01C6841F7974B9ECDF8967443") else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            if let data = data {
                do {
                    let location = try JSONDecoder().decode(Locations.self, from: data)
                    DispatchQueue.main.async {
                        self.updateUI(with: location)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }

    func updateUI(with location: Locations) {
        if let urls = location.web_url {
            self.myurl = urls
        } else {
            self.myurl = ""
        }
        
        if let name = location.name {
            self.name.text = name
        } else {
            self.name.text = "N/A"
        }

        if let address = location.address_obj?.address_string {
            self.address.text = address
        } else {
            self.address.text = "N/A"
        }

        if let phone = location.phone {
            self.phonelabel.text = phone
        } else {
            self.phonelabel.text = "N/A"
        }

        if let priceLevel = location.price_level {
            self.pricelevel.text = priceLevel
        } else {
            self.pricelevel.text = "N/A"
        }

        if let hours = location.hours {
            if let weekdayText = hours.weekday_text?.joined(separator: "\n") {
                   self.opentime.text = weekdayText
               } else {
                   self.opentime.text = "N/A"
               }
           } else {
               self.opentime.text = "N/A"
           }
        
        
        
        loadImageFromURL(urlString: DetailViewController.myimage) { (image) in
            if let image = image {
                self.myimage.image = image
            } else {
                self.myimage.image = UIImage(named: "noimage")
            }
        }
        loader.stopAnimating()
        loader.isHidden = true
    }
    
    @IBAction func detailTapped(_ sender: Any) {
        self.loader.startAnimating()
        self.loader.isHidden = false
        guard let url = URL(string: self.myurl) else {
            return
        }
        
        let safariVC = SFSafariViewController(url:url )
        self.present(safariVC, animated: true, completion: {
            // Stop the activity indicator animation and hide it
            self.loader.stopAnimating()
            self.loader.isHidden = true
        })
    }
    
    
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

struct Locations: Codable {
    let location_id: String?
    let name: String?
    let web_url: String?
    let address_obj: AddressObjs?
    let phone: String?
    let price_level: String?
    let hours: Hourss?
}

struct AddressObjs: Codable {
    let address_string: String
}

struct Hourss: Codable {
    let weekday_text: [String]?
}
