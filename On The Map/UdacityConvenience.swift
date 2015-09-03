//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Eric Winn on 7/27/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: - Login/Create User Session
    func createUserSession(username: String, password: String, completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        var method: String = Methods.AccountSignIn
        println("\tAccountSignIn method:\(method)")
        let jsonBody: [String: AnyObject] = [
            "udacity": [
                UdacityClient.JSONBodyKeys.UserName: username,
                UdacityClient.JSONBodyKeys.Password: password
            ]
        ]
        
        let task = taskForPOSTMethod(method, jsonBody: jsonBody) { JSONResult, error in
            if let error = error {
                println("taskForPOSTMethod error: \(error)")
                completionHandler(success: false, message: "Method Failed (AuthenticationSignIn).", error: error)
            } else {
                if let accountDictionary = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) as? NSDictionary {
                    if let userID = accountDictionary.valueForKey(UdacityClient.JSONResponseKeys.UserID) as? String {
                        println("Created User Session\n\tGot Udacity userID: \(userID)\n\t\tCalling getUdacityUserData(\(userID))")
                        // Try and grab the necessary logged in user data to be able to post to the map later...
                        self.getUdacityUserData(userID) { success, message, error in
                            if success {
                                completionHandler(success: true, message: message, error: nil)
                            } else {
                                println("\tError grabbing UdacityUser data: \(error)")
                                completionHandler(success: false, message: message, error: error)
                            }
                        }
                    } else {
                        // userID fubar
                        println("Got response data but could not parse userID, checking for error message and/or status message")
                        completionHandler(success: false, message: "Unable to parse UserID", error: NSError(domain: "createUserSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST session to Udacity"]))
                    }
                } else {
                    // accountDictionary fubar, check for status/error message
                    println("Unknown accountDictionary problem, checking for error message")
                    if let message = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.ErrorMessage) as? String {
                        completionHandler(success: false, message: message, error: nil)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Logout/DELETE session
    func deleteUserSession(completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        var method: String = Methods.AccountLogOut
        
        let task = taskForDELETEMethod(method) { JSONResult, error in
            if let error = error {
                println("taskForDELETEMethod error: \(error)")
                completionHandler(success: false, message: "Method Failed (AccountLogout).", error: error)
            } else {
                if let sessionDictionary = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? NSDictionary {
                    if let sessionID = sessionDictionary.valueForKey(UdacityClient.JSONResponseKeys.SessionID) as? String {
                        completionHandler(success: true, message: "Deleted User Session", error: nil)
                    } else {
                        // sessionID fubar
                        println("Got session dictionary but not session ID: \(sessionDictionary)")
                        println("JSONResult: \(JSONResult!)")
                        completionHandler(success: false, message: "Unable to parse SessionID", error: NSError(domain: "deleteUserSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse DELETE session to Udacity"]))
                    }
                } else {
                    // sessionDictionary fubar, check for status/error message
                    println("Unknown sessionDictionary problem, checking for error message")
                    if let message = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.ErrorMessage) as? String {
                        completionHandler(success: false, message: message, error: nil)
                    }
                }
            }
        }
    }
    
    
    // MARK: Get data for the Udacity User that logged in. Only called by createUserSession above.
    private func getUdacityUserData(userID: String, completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        var method: String = Methods.AccountUserData + userID
        println("\t\t\tAccountUserData method:\(method)")
        
        let task = taskForGETMethod(method) { JSONResult, error in
            if let error = error {
                println("\t\t\ttaskForGETMethod error: \(error)")
                completionHandler(success: false, message: "taskForGETMethod error getting logged in user data", error: error)
            } else {
                if let userDictionary = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? NSDictionary {
                    if let firstName = userDictionary.valueForKey(UdacityClient.JSONResponseKeys.FirstName) as? String {
                        if let lastName = userDictionary.valueForKey(UdacityClient.JSONResponseKeys.LastName) as? String {
                            udacityUser.setUdacityUser(firstName, lastName: lastName, userID: userID)
                            completionHandler(success: true, message: "Got User lastName:\(lastName)", error: nil)
                        } else {
                            completionHandler(success: false, message: "Failed to get User lastName", error: NSError(domain: "userDictionary parsing for lastName error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get User lastName"]))
                        }
                    } else {
                        completionHandler(success: false, message: "Failed to get User firstName", error: NSError(domain: "userDictionary parsing for firstName error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get User firstName"]))
                    }
                } else {
                    // userDictionary fubar, check for status/error message
                    if let message = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.ErrorMessage) as? String {
                        completionHandler(success: false, message: message, error: nil)
                    }
                }
            }
        }
    }
    
}
