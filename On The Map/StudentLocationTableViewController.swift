//
//  StudentLocationTableViewController.swift
//  On The Map
//
//  Created by Eric Winn on 8/19/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Data
    var studentLocations: [StudentLocation] = [StudentLocation]()
    
    // MARK: - Outlets
    @IBOutlet var studentLocationTableView: UITableView!
    
    // MARK: - Setup and initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background gradient
        // Useful in designing color gradients by defining 2 end colors and the number of steps between: http://www.perbang.dk/rgbgradient/
        // using 3 steps (hex)
        let baseOrange = UIColor(hex: 0xff7f00, alpha: 1.0)
        let lightOrange = UIColor(hex: 0xff9800, alpha: 1.0)
        let lighterOrange = UIColor(hex: 0xffb100, alpha: 1.0)
        self.view.layer.configureGradientBackground(baseOrange.CGColor, lightOrange.CGColor, lighterOrange.CGColor)
        
        // Initial Student Information data request
        println("\nTableView: Initial table load of Student Information")
        let qualityOfServiceClass = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qualityOfServiceClass, 0)) { () -> Void in
            println("TableView: Calling getStudentInformationCollection()")
            ParseClient.sharedInstance().getStudentInformationCollection() { success, message, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if success == false {
                        self.showMessageAlert("Initial Map Data Request", message: message)
                    }
                }
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Subscribe to notifications
        notificationCenter.addObserver(self, selector: "updateTableView", name: StudentLocationNotificationKey, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        // Unsubscribe to notifications
        notificationCenter.removeObserver(self)
    }
    
    
    func updateTableView() {
        println("Updating the Table View...")
        dispatch_async(dispatch_get_main_queue()) {
            // Get student locations
            println("\tTableView: Getting student locations...")
            self.studentLocations = globalStudentLocations
            
            // reload data
            println("\tTableView: reloading data")
            self.studentLocationTableView.reloadData()
        }
    }
    
    // MARK: - Table view delegates
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentLocations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let student = studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("studentLocationCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel!.text = student.firstName + " " + student.lastName
        if let mediaURL = student.mediaURL {
            cell.detailTextLabel!.text = mediaURL
        } else {
            cell.detailTextLabel!.text = "NO_URL_PROVIDED"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Open the URL in Safari when the row is selected
        let student = studentLocations[indexPath.row]
        // A reachable URL generally requires a valid Protocol and Resource Name.
        // Not going to extrapolate intentions - if it can't be opened or was nil to start with 
        // will alert on these two cases, otherwise pop into Safari with the "good" URL
        let mediaURL = student.mediaURL
        if mediaURL == "NO_URL_PROVIDED" {
            dispatch_async(dispatch_get_main_queue()) {
                self.showMessageAlert("Media URL", message: "This student did not provide a URL")
            }
        } else if verifyURL(mediaURL) {
            UIApplication.sharedApplication().openURL(NSURL(string: mediaURL!)!)
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.showMessageAlert("Media URL", message: "The URL provided is malformed/invalid:\n\n\"\(mediaURL!)\"")
            }
        }
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
    
    
    // MARK: - Helper: Alert Utility to display error messages
    // NOTE: Calls to this function should be inside of dispatch_asyn(dispatch_get_main_queue()) envelopes!
    func showMessageAlert(alertTitle: String, message: String) {
        var messageAlert = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
        messageAlert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(messageAlert, animated: true, completion: nil)
    }

    
}
