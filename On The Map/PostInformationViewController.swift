//
//  PostInformationViewController.swift
//  On The Map
//
//  Created by Eric Winn on 8/20/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PostInformationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var findOnTheMap: UIButton!
    @IBOutlet weak var removePinButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Variables
    var locationManager: CLLocationManager!
    var udacityUserAnnotation = MKPointAnnotation()
    var tapRecognizer: UITapGestureRecognizer? = nil
    var longPressRecognizer: UILongPressGestureRecognizer? = nil
    var swipeRecognizer: UISwipeGestureRecognizer? = nil
    var initialLocation: CLLocation? = nil
    // Set radius to 1000 meters (1km), a little more than half a mile
    let regionRadius: CLLocationDistance = 1000
    
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if udacityUser.hasPosting {
            // Editing an existing pin (student location record)
            // Requires PUT method to update the existing record
            println("Post Info: (viewDidLoad) Setting initial location from Udacity User data")
            initialLocation = CLLocation(latitude: CLLocationDegrees(udacityUser.latitude!), longitude: CLLocationDegrees(udacityUser.longitude!))
            textView.text = udacityUser.mapString
            urlTextField.text = udacityUser.mediaURL
            // Add the current record to this mapView
            annotationFromLocation(udacityUser.latitude!, long: udacityUser.longitude!)
            println("Post Info: (viewDidLoad) Setting map center and region")
            centerMapOnLocation(initialLocation!)
        } else {
            // Creating a new pin (student location record)
            // Requires POST method to add a new record
            // Default to the user's current location if available, else the default map view
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            if locationManager.location != nil {
                println("Post Info: New pin init - got current location")
                initialLocation = locationManager.location
                centerMapOnLocation(initialLocation!)
            }
        }
        
        
        // delegates
        textView.delegate = self
        urlTextField.delegate = self
        mapView.delegate = self
        
        // configure UI
        self.configureUI()

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ActivityIndicatorView.shared.hideActivityIndicatorView()
        self.addKeyboardDismissRecognizer()
        self.addLongPressGestureRecognizer()
        self.addSwipeGestureRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.removeLongPressGestureRecongnizer()
        self.removeSwipeGestureRecognizer()
        ActivityIndicatorView.shared.hideActivityIndicatorView()
    }

    // MARK: - Actions
    @IBAction func cancelPostingInformationButton(sender: UIButton) {
        println("PostInfo: Pressed Cancel button")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: UIButton) {
        if textView.text == "" {
            showMessageAlert("Location Description", message: "The location description cannot be blank.\n\nExamples:\n\t1 Infinite Loop, Cupertino, CA\n\tStoke On Trent, UK\n\tCorcovado, Brazil\n\t-22.952417, -43.211667\n\tStonehenge, UK\n\nNOTE: You can also press and hold to drop a pin")
        } else {
            annotationFromDescription(textView.text)
        }
    }
    
    @IBAction func removePinButton(sender: UIButton) {
        println("Post Info: Pressed the remove pin button")
        removePin()
    }
    
    @IBAction func submitButton(sender: UIButton) {
        println("Post Info: Pressed the submit button")
        // Check for empty or invalid URL
        println("Post Info: mediaURL: \(urlTextField.text)")
        if verifyURL(urlTextField.text) {
            var thisLocation = StudentLocation()
            thisLocation.mediaURL = urlTextField.text
            thisLocation.mapString = textView.text
            thisLocation.latitude = udacityUserAnnotation.coordinate.latitude
            thisLocation.longitude = udacityUserAnnotation.coordinate.longitude
            if udacityUser.hasPosting {
                // UPDATE the record
                println("\t UPDATE location pin: \(thisLocation)")
                ActivityIndicatorView.shared.showActivityIndicator(view.superview!)
                
                ParseClient.sharedInstance().putStudentLocationPin(thisLocation) { success, message, error in
                    if success {
                        println("\tSuccessfully Updated Location Pin!")
                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        println("\tFailed to Update Location Pin!")
                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        self.showMessageAlert("Update Error", message: message)
                    }
                }
            } else {
                // ADD the record
                println("\t ADD location pin: \(thisLocation)")
                ActivityIndicatorView.shared.showActivityIndicator(view.superview!)
                
                ParseClient.sharedInstance().postStudentLocationPin(thisLocation) { success, message, error in
                    if success {
                        println("\tSuccessfully Created Location Pin!")
                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        println("\tFailed to Create Location Pin!")
                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        self.showMessageAlert("Create Error", message: message)
                    }
                }
            }
        } else {
            self.showMessageAlert("Media URL", message: "The URL provided is malformed/invalid:\n\n\"\(urlTextField.text!)\"")
        }
    }
    
    // MARK: - Location Manager delegates
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Current location didUpdate")
        println("Current latitude: \(manager.location.coordinate.latitude)")
        println("Current longitude: \(manager.location.coordinate.longitude)")
        // Only need it once
        locationManager.stopUpdatingLocation()
        println("Current location updates stopped")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Current location error: \(error.localizedDescription)")
    }
    
    // MARK: Map Helper - center using location and region
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Annotation Helpers
    // ATTRIB: - http://stackoverflow.com/a/31304290
    func annotationFromLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            ActivityIndicatorView.shared.showActivityIndicator(self.mapView)
            // Add annotation
            println("Post Info: Adding pin with long press, 1 touch")
            var touchPoint = gestureRecognizer.locationInView(mapView)
            var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            println("Post Info: long press newCoordinates: \(newCoordinates)")
            udacityUserAnnotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    self.showMessageAlert("Reverse Geocoder Error", message: "\(error.localizedDescription)")
                    return
                }
                
                if placemarks.count > 0 {
                    let pm = placemarks[0] as! CLPlacemark
                    
                    self.udacityUserAnnotation.title = "\(udacityUser.firstName) \(udacityUser.LastName)"
                    if udacityUser.hasPosting && self.urlTextField.text == ""  {
                        self.udacityUserAnnotation.subtitle = "\(udacityUser.mediaURL)"
                        // Update the empty urlTextField
                        self.urlTextField.text = "\(udacityUser.mediaURL)"
                    } else {
                        self.udacityUserAnnotation.subtitle = self.urlTextField.text
                    }
                    self.mapView.addAnnotation(self.udacityUserAnnotation)
//                    println(pm)
                    ActivityIndicatorView.shared.hideActivityIndicatorView()
                    let addressDict: [NSString:NSObject] = pm.addressDictionary as! [NSString: NSObject]
                    let addrList = addressDict["FormattedAddressLines"] as! [String]
                    let address = ", ".join(addrList)
                    print(address)
                    self.textView.text = address
                    // Note: There is also a "url" value in the placemark pm data that might be useful
                    println("Post Info: Long Press Annotation added for address: \(address)")
                } else {
                    println("Problem with the data received from the geocoder")
                }
            })
        }
    }
    
    
    func annotationFromLocation(lat: Double, long: Double) {
        var newCoordinates = (CLLocationCoordinate2DMake(lat, long))
        udacityUserAnnotation.coordinate = newCoordinates
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                self.showMessageAlert("Reverse Geocode Location Error", message: "\(error.localizedDescription)")
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                
                self.udacityUserAnnotation.title = "\(udacityUser.firstName) \(udacityUser.LastName)"
                if udacityUser.hasPosting && self.urlTextField.text == ""  {
                    self.udacityUserAnnotation.subtitle = "\(udacityUser.mediaURL)"
                    // Update the empty urlTextField
                    self.urlTextField.text = "\(udacityUser.mediaURL)"
                } else {
                    self.udacityUserAnnotation.subtitle = self.urlTextField.text
                }
                self.mapView.addAnnotation(self.udacityUserAnnotation)
//                println(pm)
                println("Post Info: reverse geocode location succeeded")
            } else {
                println("Problem with the data received from the geocoder")
            }
        })
    }
    
    
    func annotationFromDescription(locationString: String) {
        ActivityIndicatorView.shared.showActivityIndicator(self.mapView)
        CLGeocoder().geocodeAddressString(locationString, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                ActivityIndicatorView.shared.hideActivityIndicatorView()
                self.showMessageAlert("Address Geocode Location Error", message: "\(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?[0] as? CLPlacemark {
                let pm = MKPlacemark(placemark: placemark)
                self.udacityUserAnnotation.coordinate = (CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude))
                self.udacityUserAnnotation.title = "\(udacityUser.firstName) \(udacityUser.LastName)"
                if udacityUser.hasPosting && self.urlTextField.text == ""  {
                    self.udacityUserAnnotation.subtitle = "\(udacityUser.mediaURL)"
                    // Update the empty urlTextField
                    self.urlTextField.text = "\(udacityUser.mediaURL)"
                } else {
                    self.udacityUserAnnotation.subtitle = self.urlTextField.text
                }
                self.mapView.addAnnotation(self.udacityUserAnnotation)
                self.centerMapOnLocation(pm.location)
//                println(pm)
                ActivityIndicatorView.shared.hideActivityIndicatorView()
                let addressDict: [NSString:NSObject] = pm.addressDictionary as! [NSString: NSObject]
                let addrList = addressDict["FormattedAddressLines"] as! [String]
                let address = ", ".join(addrList)
                print(address)
                self.textView.text = address
                println("Post Info: Address geocode location succeeded for address: \(address)")
                println("pm.addressDictionary: \(pm.addressDictionary)")
                // Note: There is also a "url" value in the placemark address data
            } else {
                println("Problem with the data received from the geocoder")
            }
        })
    }
    
    func removePin() {
        dispatch_async(dispatch_get_main_queue()) {
//            ActivityIndicatorView.shared.showActivityIndicator(self.view.superview!)
            println("Post Info: Removing \(self.udacityUserAnnotation.title) pin")
            var deleteAlert = UIAlertController(title: "Delete", message: "This will remove your Udacity Student Location Pin data!\n\nAre you sure?", preferredStyle: .Alert)
            deleteAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                // DELETE the location pin data from the parse data store
                ParseClient.sharedInstance().deleteStudentLocationPin() {success, message, error in
                    if success == false {
//                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        self.showMessageAlert("Delete Error", message: message)
                    } else {
//                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }))
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            self.presentViewController(deleteAlert, animated: true, completion: nil)
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
    
    // MARK: - text delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}


extension PostInformationViewController {
    
    // MARK: UI configuration
    func configureUI() {
        println("Post Info: Configuring UI()")
        let darkOrange = UIColor(hex: 0xff6e00, alpha: 1.0)
        let baseOrange = UIColor(hex: 0xff7f00, alpha: 1.0)
        let lightOrange = UIColor(hex: 0xff9800, alpha: 1.0)
        let lighterOrange = UIColor(hex: 0xffb100, alpha: 1.0)
        
        
        // Configure labelView
        labelView.layer.configureGradientBackground(darkOrange.CGColor, baseOrange.CGColor, lightOrange.CGColor, lighterOrange.CGColor)
        promptLabel.textColor = UIColor.blackColor()
        
        // Configure textView
        textView.textColor = UIColor.blackColor()

        // Configure URLView
        urlTextField.textColor = UIColor.blackColor()
        urlTextField.keyboardType = UIKeyboardType.URL
        
        // Configure media URL text field
        urlTextField.clearButtonMode = .WhileEditing
        
        // Configure button views
        buttonView.layer.configureGradientBackground(darkOrange.CGColor, baseOrange.CGColor, lightOrange.CGColor, lighterOrange.CGColor)
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        findOnTheMap.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        removePinButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    // MARK: - Recognizer helpers
    func addKeyboardDismissRecognizer() {
        println("Post Info: Add the recognizer to dismiss the keyboard")
        if tapRecognizer == nil {
            tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
            tapRecognizer!.numberOfTapsRequired = 1
            self.view.addGestureRecognizer(tapRecognizer!)
        }
    }
    
    func removeKeyboardDismissRecognizer() {
        println("Post Info: Remove the recognizer to dismiss the keyboard")
        if tapRecognizer != nil {
            self.view.removeGestureRecognizer(tapRecognizer!)
            tapRecognizer = nil
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        println("Post Info: Tapped to dismiss keyboard")
        view.endEditing(true)
    }
    
    func addLongPressGestureRecognizer() {
        if longPressRecognizer == nil {
            longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "annotationFromLongPress:")
            longPressRecognizer?.minimumPressDuration = 2.0
            mapView.addGestureRecognizer(longPressRecognizer!)
        }
    }
    
    func removeLongPressGestureRecongnizer() {
        if longPressRecognizer != nil {
            mapView.removeGestureRecognizer(longPressRecognizer!)
            longPressRecognizer = nil
        }
    }
    
    func addSwipeGestureRecognizer() {
        if swipeRecognizer == nil {
            swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDownToDismissKeyboard:")
            swipeRecognizer?.direction = .Down
            self.view.addGestureRecognizer(swipeRecognizer!)
        }
    }
    
    func removeSwipeGestureRecognizer() {
        if swipeRecognizer != nil {
            self.view.removeGestureRecognizer(swipeRecognizer!)
            swipeRecognizer = nil
        }
    }
    
    func swipeDownToDismissKeyboard(recognizer: UISwipeGestureRecognizer) {
        println("Post Info: Swiped down to dismiss keyboard")
        view.endEditing(true)
    }
    
}
