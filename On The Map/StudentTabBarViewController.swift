//
//  StudentTabBarViewController.swift
//  On The Map
//
//  Created by Eric Winn on 8/19/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit

class StudentTabBarViewController: UITabBarController {
    
    // MARK: - Outlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add right side buttons
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshStudentLocations"), UIBarButtonItem(image: UIImage(named: "pin.png"), style: .Plain, target: self, action: "addStudentLocation")]
        
        // Set the title
        self.title = "On The Map"
    }
    
    // MARK: Actions
    @IBAction func logoutFromUdacity(sender: UIBarButtonItem) {
        var logoutAlert = UIAlertController(title: "Logout", message: "Logout, are you sure?", preferredStyle: .Alert)
        logoutAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            ActivityIndicatorView.shared.showActivityIndicator(self.view.superview!)
            UdacityClient.sharedInstance().deleteUserSession { success, message, error in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        // remove the activity indicator
                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        // complete logout
                        self.completeLogout()
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        println("Udacity Logout/Delete Session Failed!")
                        // remove the activity indicator
                        ActivityIndicatorView.shared.hideActivityIndicatorView()
                        // show alert about any returned errors
                        self.showMessageAlert("Udacity Logout Error", message: message)
                    }
                }
            }
        }))
        logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        self.presentViewController(logoutAlert, animated: true, completion: nil)
    }
    
    // Pressed the Pin button on the top bar
    func addStudentLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PostInformationViewController") as! PostInformationViewController
        if udacityUser.hasPosting {
            println("*** ===================================== ***")
            println("Tapped Post Pin to Edit:")
            println("\thasPosting: \(udacityUser.hasPosting)")
            println("\tfirstName: \(udacityUser.firstName)")
            println("\tlastName: \(udacityUser.LastName)")
            println("\tobjectID: \(udacityUser.objectID)")
            println("\tmapString: \(udacityUser.mapString)")
            println("\tmediaURL: \(udacityUser.mediaURL)")
            println("\tlatitude: \(udacityUser.latitude!)")
            println("\tlongitude: \(udacityUser.longitude!)")
            println("\tcreatedAt: \(udacityUser.createdAt)")
            println("\tupdatedAt: \(udacityUser.updatedAt)")
            println("*** ===================================== ***")
            var postingAlert = UIAlertController(title: "Map Location Pin", message: "A location pin already exists for\n\"\(udacityUser.firstName) \(udacityUser.LastName)\"\n\nWould you like to edit?", preferredStyle: .Alert)
            postingAlert.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { action in
                self.presentViewController(controller, animated: true, completion: nil)
            }))
            postingAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            self.presentViewController(postingAlert, animated: true, completion: nil)
        } else {
            // Logged on Udacity user has not posted a pin record yet
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // Pressed the refresh button on the top bar
    // ATTRIB: - QOS Class http://stackoverflow.com/a/25070476
    func refreshStudentLocations() {
        var refreshAlert = UIAlertController(title: "Refresh Student Data", message: "Check for updated or new Student Information?", preferredStyle: .Alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            ActivityIndicatorView.shared.showActivityIndicator(self.view.superview!)
            let qualityOfServiceClass = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qualityOfServiceClass, 0)) { () -> Void in
                
                // Clear local student data
                println("Refresh: Clearing \(globalStudentLocations.count) local student records")
                globalStudentLocations.removeAll(keepCapacity: false)
                
                // Load fresh data from Udacity/Parse
                ParseClient.sharedInstance().getStudentInformationCollection() { success, message, error in
                    if success == false {
                        dispatch_async(dispatch_get_main_queue()) {
                            ActivityIndicatorView.shared.hideActivityIndicatorView()
                            self.showMessageAlert("Refresh", message: message)
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            ActivityIndicatorView.shared.hideActivityIndicatorView()
                        }
                    }
                }
            }
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        self.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    // NOTE: Calls to this function should be inside of dispatch_asyn(dispatch_get_main_queue()) envelopes!
    func completeLogout() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Helper: Alert Utility to display error messages
    func showMessageAlert(alertTitle: String, message: String) {
        var messageAlert = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
        messageAlert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(messageAlert, animated: true, completion: nil)
    }

    
}
