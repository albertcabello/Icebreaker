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


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var networkController:NetworkController!
    private let locationManager = CLLocationManager()
    private let mapView = MKMapView()
    private var shownUsers: [String: UserAnnotation] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set up the map and its type
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
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
        
            let settings = UIAlertAction(title: "Settings", style: .default) { (action) in
                if let appSetting = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(appSetting)
                }
            }
            print("Authorization Denied")
            self.present(alertGenerator(title: "Location Services Disabled", message: "In order for us to connect you with other users, please turn on location services", actions: settings), animated: true, completion: nil)
            
            
        }
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
//            let userLocation = locationManager.location     //The users location as a CLLocation Object
//            let coordinates = userLocation?.coordinate      //The users location as a CLLocationCoordinate2D Object
//            let longitude = coordinates?.longitude          //The users longitude as a CLLocationDegrees Object
//            let latitude = coordinates?.latitude            //The users latitude as a CLLocationDegrees Object
            
            
            //Update the MySQL coordinates with actual coordinates
            updateServer()
            
            //Initialize the latitude and longitude labels
            
//            let latLabel = UILabel(frame: CGRect(x: 20.0, y: self.view.frame.height - 60.0, width: self.view.frame.width - 40.0, height: 30.0))
//            latLabel.text = "Latitude: " + (latitude?.description)!   //Turn latitude into a string
//            latLabel.backgroundColor = UIColor.white
//            print("latLabel set")
//            let longLabel = UILabel(frame: CGRect(x: 20.0, y: self.view.frame.height - 90.0, width: self.view.frame.width - 40.0, height: 30.0))
//            longLabel.text = "Longitude: " + (longitude?.description)! //Turn latitude into a string
//            longLabel.backgroundColor = UIColor.white
//            print("longLabel set")
            
            //Adds the longitude and latitude labels to the view
            //self.view.addSubview(latLabel); self.view.addSubview(longLabel); print("latLabel and longLabel added to view")
            
            //Update the mySQL database after significant changes
            var _ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (Timer) in
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
    
    /*
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
     * This function has three primary steps
     * 1) Delete any users that are no longer in range or not active
     * 2) Update the users that are still shown and moving
     * 3) Add in any new users 
     * I may end up making the change in annotation coordinates an animation instead of a jump
     */
    func showNearbyUsers() {
        networkController.getNearbyUsers() { users in
            //Delete the entire dictionary
            self.shownUsers.removeAll()
            
            //This block will readd in all the users
            for user in users {
                let annotation = UserAnnotation(user: user)
                self.shownUsers[user.getName()] = annotation
            }
            
            //If the mapview has no annotations, just add all of them in 
            if (self.mapView.annotations.isEmpty) {
                self.mapView.addAnnotations(Array(self.shownUsers.values))
            }
            
            //This block will update the shown annotations
            //Loop through all the shown annotations
            for existingAnnotation in self.mapView.annotations {
                //Cast the existing annotation to the UserAnnotation because the coordinate property of MKAnnotation is get only
                if let annotation = existingAnnotation as? UserAnnotation {
                    //Check if the shownUsers dictionary contains the annotation and the updated coordinates
                    if let updatedCoordinates = self.shownUsers[annotation.title!]?.coordinate {
                        UIView.animate(withDuration: 5) { Void in
                            annotation.coordinate = updatedCoordinates
                        }
                    }
                    //If the dictionary didn't have the updated coordinates, that means the user was removed from the dictionary so remove 
                    //it from the map
                    else {
                        self.mapView.removeAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    //The function to be called when the callout bubble on an annotation is pressed
    func calloutTapped() {
        //Eventually this will go to the interests screen of the selected user
        print("Callout tapped")
    }
    
    //Add a gesture recognizer to each callout so that I can tell when it's pressed
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //Initialize the gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(calloutTapped))
        view.addGestureRecognizer(tap)
    }
    
    //Adds image to the annotation callout
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        print("delegate called")
        if (annotation is MKUserLocation) {
            return nil
        }
        let reuseId = "userAnnotation"
        var anview = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        anview?.canShowCallout = true
        if (anview == nil) {
//            print("anview = nil")
            anview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anview?.canShowCallout = true
//            print(anview?.annotation?.title!)
            let img = UIImage(named: "Logo.png")
            let imgView = UIImageView(image: img)
            imgView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            anview?.leftCalloutAccessoryView = imgView
        }
        else {
//          print("anview not nil")
            anview?.annotation = annotation
        }
//        print("Returning view")
        return anview
    }
    
    //Detecs when the button is called
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //The button on the user location was tapped
        if (view.annotation is MKUserLocation) {
            let nvc = UINavigationController(rootViewController: self)
            let profileView = ProfileViewController()
            profileView.networkController = networkController
            profileView.nvc = nvc
            self.present(profileView, animated: true, completion: nil)
        }
    }
    
    //Adds a button to the user annotation, NOT THE PINS
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if (view.annotation is MKUserLocation) {
                let anview = view
                let profileButton = UIButton(type: .detailDisclosure)
                anview.rightCalloutAccessoryView = profileButton
            }
        }
    }
    
    /*
     * Updates the user coordinates on the mySQL server
     */
    func updateServer() {
        let coordinates = locationManager.location?.coordinate
        networkController.updateServer(latitude: (coordinates?.latitude)!, longitude: (coordinates?.longitude)!) { response in
            if response != 1 {
                let alert = UIAlertController(title: "Could not update location", message: "Something went wrong with updating your location to the server, please try again later", preferredStyle: .alert)
                let lvc = LoginViewController()
                lvc.view.backgroundColor = UIColor.white
                let okAction = UIAlertAction(title: "OK", style: .default) { Void in
                    self.present(lvc, animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
} //Class ends
