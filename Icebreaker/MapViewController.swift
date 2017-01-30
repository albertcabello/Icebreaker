//
//  ViewController.swift
//  Testing
//
//  Created by Alberto Cabello on 9/23/16.
//  Copyright © 2016 Alberto Cabello. All rights reserved.
//
import UIKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON


class MapViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let mapView = MKMapView()
    private let username:String
    private let password:String
    
    init(username:String, password:String) {
        self.username = username
        self.password = password
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set up the map and its type
        mapView.mapType = .standard
        
        //Request location services access
        locationManager.requestAlwaysAuthorization()
        
        //Checks if location services are enabled, if they are, initialize the delegate, the accuracy, and start updating the heading and location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            loadMap()
            
        }
        //Set the view to be the map
        view = mapView
        
        //Get initial nearby users
        showNearbyUsers()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Checks for whether location services is enabled
        if CLLocationManager.authorizationStatus() == .denied {
            //Create the UIAction that opens settings
            
            
            //So going back after around two months of doing this, I have no idea why that handler works.  What does the compiler
            //think (action) is?  Oh well, I'll figure it out later 
            let settings = UIAlertAction(title: "Settings", style: .default) { (action) in
                if let appSetting = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(appSetting)
                }
            }
            print("Authorization Denied")
            self.present(alertGenerator(title: "Location Services Disabled", message: "In order for us to connect you with other users, please turn on location services", actions: settings), animated: true, completion: nil)
            
            
        }
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            let userLocation = locationManager.location     //The users location as a CLLocation Object
            let coordinates = userLocation?.coordinate      //The users location as a CLLocationCoordinate2D Object
            let longitude = coordinates?.longitude          //The users longitude as a CLLocationDegrees Object
            let latitude = coordinates?.latitude            //The users latitude as a CLLocationDegrees Object
            
            
            //Update the MySQL coordinates with actual coordinates
            updateServer()
            
            //Initialize the latitude and longitude labels
            let latLabel = UILabel(frame: CGRect(x: 20.0, y: self.view.frame.height - 60.0, width: self.view.frame.width - 40.0, height: 30.0))
            latLabel.text = "Latitude: " + (latitude?.description)!   //Turn latitude into a string
            latLabel.backgroundColor = UIColor.white
            print("latLabel set")
            let longLabel = UILabel(frame: CGRect(x: 20.0, y: self.view.frame.height - 90.0, width: self.view.frame.width - 40.0, height: 30.0))
            longLabel.text = "Longitude: " + (longitude?.description)! //Turn latitude into a string
            longLabel.backgroundColor = UIColor.white
            print("longLabel set")
            
            //Adds the longitude and latitude labels to the view
            self.view.addSubview(latLabel); self.view.addSubview(longLabel); print("latLabel and longLabel added to view")
            
            //Update the mySQL database after significant changes
            var timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (Timer) in
                self.updateServer()
                self.showNearbyUsers()})
            
            
        }
        
    }
    
    //Sets the map to start tracking the user with heading enabled
    func loadMap() {
        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        //Span of the mapView
        let mapSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1.0/60.0), longitudeDelta: CLLocationDegrees(1.0/60.0))
        //Region of the mapView
        let mapRegion = MKCoordinateRegion(center: (locationManager.location?.coordinate)!, span: mapSpan)
        //Apply region to the mapView
        mapView.region = mapRegion
    }
    
    /**
     * -Parameters:
     *   - title: The desired title for the alert
     *   - message: The desired message for the alert
     *   - actions: An array of UIAlertActions that will be implemented into the alert
     * -Returns: A UIAlertController with all of the parameters implemented
     */
    func alertGenerator(title: String, message: String, actions: UIAlertAction...) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        return alert
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
     * This function will get all nearby users based on the given username and password
     * There is no error handling in case of bad username, password, or action because I made the API and know that this url works
     */
    func showNearbyUsers() {
        //The URL we will use the get request on to get nearby users
        let url = "http://localhost:8000/?action=get&userGiven=\(self.username)&passGiven=\(self.password)"
        
        //Use Alamofire to perform the request
        Alamofire.request(url).responseJSON { response in
            let json = JSON(response.result.value!)
            //Loop through API JSON response
            var i = 0;
            for (_, subJson):(String, JSON) in json {
                //Get longitude and latitude and create the annotation
                let latitude = Double(subJson["latitude"].stringValue)!
                let longitude = Double(subJson["longitude"].stringValue)!
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = subJson["username"].stringValue
                //Display annotation on map
                self.mapView.addAnnotation(annotation)
                //Limit amount of annotations to 10 to prevent CPU overload
                i += 1
                if (i == 10) {
                    break
                }
            }
            
        }
        NSLog("Successful nearby user update")
        
    
    }
    /*
     * Updates the user coordinates on the mySQL server
     */
    func updateServer() {
        let coordinates = locationManager.location?.coordinate
        let latitude = coordinates?.latitude
        let longitude = coordinates?.longitude
        //The URL we will send the coordinates to so the MySQL server can be updated
        let url = "http://localhost:8000/?action=update&userGiven=\(self.username)&passGiven=\(self.password)&latitude=\(latitude!)&longitude=\(longitude!)"
        //Use Alamofire to connect to the URL
        Alamofire.request(url).responseString { response in
            //I wrote the webservice, it's definitely going to give an answer
            if response.result.value == "1" {
                NSLog("Successful coordinate update")
            }
            else {
                NSLog("Unsuccessful coordinate update, returning to login screen")
                let alert = UIAlertController(title: "Could not update location", message: "Something went wrong with updating your location to the server, please try again later", preferredStyle: .alert)
                let lvc = LoginViewController()
                lvc.view.backgroundColor = UIColor.white
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { Void in
                    self.present(lvc, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
} //Class ends
