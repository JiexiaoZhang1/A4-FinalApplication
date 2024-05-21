
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var startstopLabel: UILabel! // Label to display "Start" or "Stop"
    
    @IBOutlet weak var totaldistanceLabel: UILabel! // Label to display total distance
    @IBOutlet weak var speedLabel: UILabel! // Label to display speed
    @IBOutlet weak var bottomView: UIView! // View at the bottom of the screen
    
    // MARK: Map & Location related stuff
    
    @IBOutlet weak var myMap: MKMapView! // Map view to display the map
    
    var locationManager = CLLocationManager() // Location manager to manage user's location
    
    var firstRun = true // Flag to check if it's the first run
    var startTrackingTheUser = false // Flag to indicate if tracking the user's location is enabled
    var userLocations: [CLLocation] = [] // Array to store user's locations
    var currentPolyline: MKPolyline? // Reference to the current polyline
    
    // MARK: View related Stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.layer.cornerRadius = 20 // Set corner radius for the bottom view
        tapCount = 0 // Initial tap count
        myMap.delegate = self // Set this view controller as the delegate of the map view
        
        locationManager.delegate = self // Set this view controller as the delegate of the location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // Set the desired accuracy for the user's location
        locationManager.requestWhenInUseAuthorization() // Request authorization to access the user's location
        locationManager.startUpdatingLocation() // Start updating the user's location
        
        myMap.showsUserLocation = true // Show the user's location on the map
        startTrackingTheUser = false // Disable tracking the user's location by default
    }
    
    func drawPolyline() {
        // Remove the old polyline
        
        // Create a CLLocationCoordinate2D array based on the points in userLocations
        let coordinates = userLocations.map { $0.coordinate }
        
        // Create a new polyline
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        myMap.addOverlay(polyline)
        
        // Update the reference to the current polyline
        currentPolyline = polyline
    }
    
    var lastLocation: CLLocation? // Reference to the last recorded location
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let locationOfUser = userLocation.location // Get the CLLocation object
        
        guard let validLocation = locationOfUser else { return } // Make sure locationOfUser is not nil
        
        if startTrackingTheUser {
            myMap.setCenter(validLocation.coordinate, animated: true) // Set the center of the map to the user's location
            
            if let lastLocation = lastLocation {
                let distance = validLocation.distance(from: lastLocation) // Calculate the distance between the current and last recorded location
                totalDistance += distance // Update the total distance
                totaldistanceLabel.text = String(format: "%.2f m", totalDistance) // Update the total distance label on the interface
            }
            
            lastLocation = validLocation
            userLocations.append(validLocation) // Add the CLLocation object to the userLocations array
            drawPolyline() // Draw the polyline on the map
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .green // Set the color of the polyline
            renderer.lineWidth = 5.0 // Set the line width of the polyline
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationOfUser = locations.first else { return } // Use guard statement to ensure there is location information

        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude

        if firstRun {
            firstRun = false
            let latDelta: CLLocationDegrees = 0.001
            let lonDelta: CLLocationDegrees = 0.001
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let region = MKCoordinateRegion(center: locationOfUser.coordinate, span: span)
            self.myMap.setRegion(region, animated: true)

        }
        
        // If start tracking the user, print the current latitude and longitude whenever the location updates
        if startTrackingTheUser {
            myMap.setCenter(locationOfUser.coordinate, animated: true)
            // print("Current latitude: \(latitude), longitude: \(longitude)")
        }
    }
    
    @IBOutlet weak var startstopbutton: UIButton!
    var tapCount = 0
    var totalDistance: CLLocationDistance = 0.0

    var timer = Timer()
    var seconds = 0

    @IBAction func startstopTapped(_ sender: Any) {
        if tapCount % 2 == 0 {
            // Stop
            startstopLabel.text = "Stop"
            startstopbutton.setImage(UIImage(systemName: "pause"), for: .normal)
            self.startTrackingTheUser = true
            
            // Start timer
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        } else {

            // Stop timer
            timer.invalidate()
            // Start
            startstopLabel.text = "Start"
            self.startTrackingTheUser = false
            startstopbutton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
        
        tapCount += 1
    }

    @objc func updateTimer() {
        seconds += 1
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        // Update label with formatted time
        speedLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    
}

