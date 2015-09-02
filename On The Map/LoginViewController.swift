//
//  LoginViewController.swift
//  On The Map
//
//  Created by Eric Winn on 8/1/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    
    
    // MARK: - Variables
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        self.loginEmail.delegate = self
        self.loginPassword.delegate = self
        self.configureUI()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ActivityIndicatorView.shared.hideActivityIndicatorView()
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // placeholder to explore further keyboard manipulation logic at a later date
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            println("landscape")
        } else {
            println("portraight")
        }
    }

    @IBAction func loginToUdacity(sender: UIButton) {
        // dismiss the keyboard if present
        self.view.endEditing(true)
        println("Pressed the login button")
        if let email = loginEmail.text,
           let password = loginPassword.text {
            ActivityIndicatorView.shared.showActivityIndicator(view)
            println("Attempting to create a Udacity session")
            UdacityClient.sharedInstance().createUserSession(email, password: password) { success, message, error in
                if success {
                    // complete login
                    self.completeLogin()
                } else {
                    // show alert about any returned errors
                    println("Udacity Login/Create Session Failed! \(error)")
                    self.showMessageAlert("Udacity Login Error", message: message)
                }
            }
        } else {
            // show alert about field entry errors
            println("Email and/or password is either incorrect or missing, please try again.")
            self.showMessageAlert("Login credentials error", message: "Email and/or password is either incorrect or missing, please try again.")
        }
    }
    
    
    func completeLogin() {
        ActivityIndicatorView.shared.hideActivityIndicatorView()
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("StudentNavigationController") as! UINavigationController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    // MARK: - Helper: Alert Utility to display error messages
    func showMessageAlert(alertTitle: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            ActivityIndicatorView.shared.hideActivityIndicatorView()
            var messageAlert = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
            messageAlert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(messageAlert, animated: true, completion: nil)
        }
    }
    
}


// MARK: UI configuration
extension LoginViewController {
    
    func configureUI() {
        // Configure background gradient
        // useful in designing color gradients by defining 2 end colors and the number of steps between: http://www.perbang.dk/rgbgradient/
        // ATTRIB: - http://stackoverflow.com/a/31124062
        // ATTRIB: - http://www.codingexplorer.com/create-uicolor-swift/
        // using 3 steps (RGB)
        let baseOrange = UIColor(red: 255, green: 127, blue: 0)
        let lightOrange = UIColor(red: 255, green: 152, blue: 0)
        let lighterOrange = UIColor(red: 255, green: 177, blue: 0)
        self.view.layer.configureGradientBackground(baseOrange.CGColor, lightOrange.CGColor, lighterOrange.CGColor)

        
        // Configure login label
        loginLabel.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        loginLabel.textColor = UIColor.whiteColor()
        
        // Configure Email login field
        loginEmail.keyboardType = UIKeyboardType.EmailAddress
        loginEmail.autocorrectionType = .No
        loginEmail.clearButtonMode = .WhileEditing
        
        // Configure Password login field
        loginPassword.autocorrectionType = .No
        loginPassword.clearButtonMode = .WhileEditing
        loginPassword.secureTextEntry = true
        
        // Configure login button
        let darkOrange = UIColor(red: 255, green: 110, blue: 0)
        loginButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        loginButton.layer.backgroundColor = darkOrange.CGColor
        loginButton.layer.cornerRadius = 5
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
}


// MARK: - Keyboard helpers
extension LoginViewController {
    
    func subscribeToKeyboardNotifications() {
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        notificationCenter.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = -getKeyboardHeight(notification)
    }

    func keyboardWillHide(notification: NSNotification) {
        // Just return origin to it's default since this should not be changing for this app
        self.view.frame.origin.y = 0.0
    }
    
    // MARK: - Tap recognizer functions
    func addKeyboardDismissRecognizer() {
        if tapRecognizer == nil {
            tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
            tapRecognizer!.numberOfTapsRequired = 1
            self.view.addGestureRecognizer(tapRecognizer!)
        }
    }
    
    func removeKeyboardDismissRecognizer() {
        if tapRecognizer != nil {
            self.view.removeGestureRecognizer(tapRecognizer!)
            tapRecognizer = nil
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
