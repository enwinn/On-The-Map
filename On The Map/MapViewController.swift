//
//  MapViewController.swift
//  On The Map
//
//  Created by Eric Winn on 8/19/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Data
    var studentLocations: [StudentLocation] = [StudentLocation]()
    var annotations = [MKPointAnnotation]()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Setup and initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate - rightCalloutAccessoryView won't work without this!
        mapView.delegate = self
        
        // Set the background gradient
        // Useful in designing color gradients by defining 2 end colors and the number of steps between: http://www.perbang.dk/rgbgradient/
        // using 3 steps (hex)
        let baseOrange = UIColor(hex: 0xff7f00, alpha: 1.0)
        let lightOrange = UIColor(hex: 0xff9800, alpha: 1.0)
        let lighterOrange = UIColor(hex: 0xffb100, alpha: 1.0)
        self.view.layer.configureGradientBackground(baseOrange.CGColor, lightOrange.CGColor, lighterOrange.CGColor)
        
        // Initial Student Information data request
        println("\nInitial map load of Student Information")
        let qualityOfServiceClass = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qualityOfServiceClass, 0)) { () -> Void in
            println("Calling getStudentInformationCollection()")
            ParseClient.sharedInstance().getStudentInformationCollection() { success, message, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if success == false {
                        self.showMessageAlert("Initial Map Data Request", message: message)
                    }
                }
            }
        }

        // Initial update
        updateMapView()
//        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Subscribe to notifications
        notificationCenter.addObserver(self, selector: "updateMapView", name: StudentLocationNotificationKey, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        // Unsubscribe to notifications
        notificationCenter.removeObserver(self)
        // Remove any AIs
        ActivityIndicatorView.shared.hideActivityIndicatorView()
    }
    
    
    func updateMapView() {
        // Update the UI on the main thread
        println("Updating the Map View...")
        var mediaURL = ""
        var createdAt = ""
        var updatedAt = ""
        dispatch_async(dispatch_get_main_queue()) {
            
            // clear existing annotations
            println("\tMapView: Clearing any existing annotations...")
            if self.mapView.annotations.count > 0 {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.annotations.removeAll(keepCapacity: true)
            }
            
            // Get student locations
            println("\tMapView: Getting student locations...")
            self.studentLocations = globalStudentLocations
            println("\tMapView: globalStudentLocations.count: \(globalStudentLocations.count)")
            println("\tMapView: Looping through student dictionary")
            for student in self.studentLocations {
                
                let lat = CLLocationDegrees(student.latitude!)
                let long = CLLocationDegrees(student.longitude!)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let firstName = student.firstName
                let lastName = student.lastName
                let uniqueKey = student.uniqueKey
                
                if student.mediaURL != nil {
                    mediaURL = student.mediaURL!
                } else {
                    mediaURL = "NO_URL_PROVIDED"
                }
                
                if udacityUser.userID == uniqueKey {
                    // Guard for unexpected multiple records case
                    if udacityUser.hasPosting == false {
                    
                        // Check for nil and/or convert to String
                        if student.createdAt != nil {
                            createdAt = "\(student.createdAt)"
                        } else {
                            createdAt = ""
                        }
                        
                        // Check for nil and/or convert to String
                        if student.updatedAt != nil {
                            updatedAt = "\(student.updatedAt)"
                        } else {
                            updatedAt = ""
                        }
                        println("*** ===================================== ***")
                        println("Found logged on Udacity User pin record!")
                        println("\t\(firstName) \(lastName)")
                        println("\tuserID: \(uniqueKey)")
                        println("\tobjectID: \(student.objectID)")
                        println("\tmapString: \(student.mapString)")
                        println("\tmediaURL: \(mediaURL)")
                        println("\tlat: \(student.latitude!)")
                        println("\tlon: \(student.longitude!)")
                        println("\tcreatedAt: \(createdAt)")
                        println("\tupdatedAt: \(updatedAt)")
                        println("*** ===================================== ***")
                        
                        // Save to the logged on Udacity Student record
                        udacityUser.setStudentLocation(true,
                            objectID: student.objectID,
                            mapString: student.mapString,
                            mediaURL: mediaURL,
                            latitude: student.latitude!,
                            longitude: student.longitude!,
                            createdAt: createdAt,
                            updatedAt: updatedAt)
                    } else {
                        println()
                        println("!!!! ERROR: Found more than one pin record for the logged on Udacity user!")
                        println("\t\(firstName) \(lastName)")
                        println("\tuserID: \(uniqueKey)")
                        println("\tobjectID: \(student.objectID)")
                        println("\tmapString: \(student.mapString)")
                        println("\tmediaURL: \(mediaURL)")
                        println("\tlat: \(lat)")
                        println("\tlon: \(long)")
                        println("\tcreatedAt: \(student.createdAt)")
                        println("\tupdatedAt: \(student.updatedAt)")
                        println()
                    }
                }
                
                // create the annotation and set its coordinate, title, and subtitle properties
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                self.annotations.append(annotation)
            }
            
            // Add the annotations to the map
            println("\tMapView: Finished looping through the student dictionary...")
            println("\tMapView: Adding the annotations to the map and showing them...")
            self.mapView.addAnnotations(self.annotations)
//            self.mapView.showAnnotations(self.annotations, animated: true)
        }
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Green
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // MARK: - MKMapViewDelegate to open a link in Safari
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if annotationView.annotation.subtitle != nil {
            if control == annotationView.rightCalloutAccessoryView {
                let app = UIApplication.sharedApplication()
                // A reachable URL generally requires a valid Protocol and Resource Name.
                // Not going to extrapolate intentions - if it can't be opened or was nil to start with
                // will alert on these two cases, otherwise pop into Safari with the "good" URL
                let mediaURL = annotationView.annotation.subtitle!
                if mediaURL == "NO_URL_PROVIDED" {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showMessageAlert("Media URL", message: "This student did not provide a URL")
                    }
                } else if verifyURL(mediaURL) {
                    app.openURL(NSURL(string: mediaURL!)!)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showMessageAlert("Media URL", message: "The URL provided is malformed/invalid:\n\n\"\(mediaURL!)\"")
                    }
                }
                
                
            }
        }
    }
    
    // MARK: - Helper: Alert Utility to display error messages
    // NOTE: Calls to this function should be inside of dispatch_asyn(dispatch_get_main_queue()) envelopes!
    func showMessageAlert(alertTitle: String, message: String) {
        ActivityIndicatorView.shared.hideActivityIndicatorView()
        var messageAlert = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
        messageAlert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(messageAlert, animated: true, completion: nil)
    }
    
    // MARK: - URL Validation Helper
    // ATTRIB: - http://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift
    func verifyURL(urlString: String?) -> Bool {
        // Check for nil
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                // Check it
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }



}
