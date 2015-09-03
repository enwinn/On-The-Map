//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Eric Winn on 7/27/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit
import Foundation

extension ParseClient {
    
    // MARK: - Get StudentLocation Collection
    func getStudentInformationCollection(completionHandler: (sucess: Bool, message: String, error: NSError?) -> Void) {
        // grab the first 100 data records NOTE: These are small records, may need to review if they get larger...
        println("getting first 100 student records")
        getStudentInformation(100, skip: 0, completionHandler: completionHandler)
    }
    
    func getStudentInformation(limit: Int, skip: Int, completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        var method = Methods.StudentCollection
        println("getStudentInformation method: \(method)")
        var parameters = [
            ParameterKeys.Limit : "\(limit)",
            ParameterKeys.Skip : "\(skip)",
            ParameterKeys.Order : "-updatedAt"
        ]
        println("getStudentInformation paramters: \(parameters)")
        
        let task = taskForGETMethod(method, parameters: parameters) { JSONresult, error in
            if let error = error {
                println("Got an error: \(error.localizedDescription)")
                completionHandler(success: false, message: "Method Failed (StudentCollection).", error: error)
            } else {
                if let results = JSONresult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String: AnyObject]] {
                    var studentLocations = StudentLocation.studentLocationFromResults(results)
                    globalStudentLocations += studentLocations
                    if studentLocations.count == limit {
                        // grab the next set
                        var newSkip = skip + limit
                        println("Pulled in \(newSkip-limit) records, checking recursively to see if there are more")
                        self.getStudentInformation(limit, skip: newSkip, completionHandler: completionHandler)
                    } else {
                        println("Done getting records. globalStudentLocations.count: \(globalStudentLocations.count)")
                        completionHandler(success: true, message: "Got \(studentLocations.count) student information/location records", error: nil)
                    }
                } else {
                    completionHandler(success: false, message: "Error parsing getStudentInformation results", error: NSError(domain: "getStudentInformation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentInformation"]))
                }
            }
        }
    }
    
    
    // MARK: - Update a student location pin
    func putStudentLocationPin(studentLocation: StudentLocation, completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        let objectID = udacityUser.objectID
        var method: String = Methods.StudentElement + "/" + objectID
        println("putStudentLocationPin method: \(method)")
        let JSONBody = makeJSONBody(studentLocation)
        println("putStudentLocationPin JSONBody: \(JSONBody)")
        
        let task = taskForPUTMethod(method, jsonBody: JSONBody) { JSONResult, error in
            if let error = error {
                println("putStudentLocationPin Got an error \(error.localizedDescription)")
                completionHandler(success: false, message: "Method Failed PUT:(StudentElement).\nError:\(error.localizedDescription)", error: error)
            } else {
                println("putStudentLocationPin JSONResult: \(JSONResult)")
                if let updatedAt = JSONResult.valueForKey(ParseClient.JSONResponseKeys.UpdatedAt) as? String {
                    let createdAt = udacityUser.createdAt
                    println("Udacity User Student Location data updated: \(updatedAt)")
                    println("Refeshing local data after user location pin updated")
                    udacityUser.setStudentLocation(true,
                        objectID: objectID,
                        mapString: studentLocation.mapString,
                        mediaURL: studentLocation.mediaURL!,
                        latitude: studentLocation.latitude!,
                        longitude: studentLocation.longitude!,
                        createdAt: createdAt,
                        updatedAt: updatedAt)
                    
                    // Clear local student data
                    println("Updated Pin: Clearing \(globalStudentLocations.count) local student records")
                    globalStudentLocations.removeAll(keepCapacity: false)

                    // Load fresh data from Udacity/Parse
                    self.getStudentInformationCollection(completionHandler)
                    
                    completionHandler(success: true, message: "Successful Update", error: nil)
                } else {
                    println("Error parsing JSONResult for updatedAt")
                    completionHandler(success: false, message: "Error parsing putStudentLocationPin for updatedAt", error: NSError(domain: "putStudentLocationPin parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse putStudentLocationPin"]))
                }
            }
        }
    }
    
    // MARK: - Add a student location pin
    func postStudentLocationPin(studentLocation: StudentLocation, completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        println("postStudentLocationPin studentLocation: \(studentLocation)")
        var method: String = Methods.StudentElement
        println("postStudentLocationPin method: \(method)")
        let JSONBody = makeJSONBody(studentLocation)
        println("postStudentLocationPin JSONBody: \(JSONBody)")
        
        let task = taskForPOSTMethod(method, jsonBody: JSONBody) { JSONResult, error in
            if let error = error {
                println("postStudentLocationPin Got an error \(error.localizedDescription)")
                completionHandler(success: false, message: "Method Failed POST:(StudentElement).", error: error)
            } else {
                println("postStudentLocationPin JSONResult: \(JSONResult)")
                if let objectID = JSONResult.valueForKey(ParseClient.JSONResponseKeys.ObjectID) as? String {
                    if let createdAt = JSONResult.valueForKey(ParseClient.JSONResponseKeys.CreatedAt) as? String {
                        println("Udacity User Student Location data created: \(objectID)")
                        println("Saving to local User data")
                        udacityUser.setStudentLocation(true,
                            objectID: objectID,
                            mapString: studentLocation.mapString,
                            mediaURL: studentLocation.mediaURL!,
                            latitude: studentLocation.latitude!,
                            longitude: studentLocation.longitude!,
                            createdAt: createdAt,
                            updatedAt: "")
                        
                        // Clear local student data
                        println("Added Pin: Clearing \(globalStudentLocations.count) local student records")
                        globalStudentLocations.removeAll(keepCapacity: false)
                        
                        // Load fresh data from Udacity/Parse
                        self.getStudentInformationCollection(completionHandler)
                        
                        completionHandler(success: true, message: "Successful Update", error: nil)
                    } else {
                        println("Error parsing JSONResult for createdAt")
                        completionHandler(success: false, message: "Error parsing postStudentLocationPin for createdAt", error: NSError(domain: "postStudentLocationPin parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocationPin"]))
                    }
                } else {
                    println("Error parsing JSONResult for objectID")
                    completionHandler(success: false, message: "Error parsing postStudentLocationPin for objectID", error: NSError(domain: "postStudentLocationPin parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocationPin"]))
                }
            }
        }
        
    }
    
    
    // MARK: - Delete a student location pin
    func deleteStudentLocationPin(completionHandler: (success: Bool, message: String, error: NSError?) -> Void) {
        let objectID = udacityUser.objectID
        var method: String = Methods.StudentElement + "/" + objectID
        
        let task = taskForDELETEMethod(method) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, message: "Method failed DELETE(StudentElement).\nError:\(error.localizedDescription)", error: error)
            } else {
                if let message = JSONResult.valueForKey(ParseClient.JSONResponseKeys.ErrorMessage) as? String {
                    completionHandler(success: false, message: message, error: nil)
                } else {
                    // Nothing returned on successful  DELETE...
                    udacityUser.setStudentLocation(false,
                        objectID: "",
                        mapString: "",
                        mediaURL: "",
                        latitude: 0.0,
                        longitude: 0.0,
                        createdAt: "",
                        updatedAt: "")
                    
                    // Clear local student data
                    println("Added Pin: Clearing \(globalStudentLocations.count) local student records")
                    globalStudentLocations.removeAll(keepCapacity: false)
                    
                    // Load fresh data from Udacity/Parse
                    self.getStudentInformationCollection(completionHandler)
                }
            }
        }
    }
    

    
    // MARK: - JSON helper
    private func makeJSONBody(studentLocation: StudentLocation) -> [String: AnyObject] {
        let JSONBody: [String: AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: udacityUser.userID as String,
            ParseClient.JSONBodyKeys.FirstName: udacityUser.firstName as String,
            ParseClient.JSONBodyKeys.LastName: udacityUser.LastName as String,
            ParseClient.JSONBodyKeys.MapString: studentLocation.mapString as String,
            ParseClient.JSONBodyKeys.MediaURL: studentLocation.mediaURL as String!,
            ParseClient.JSONBodyKeys.Latitude: studentLocation.latitude as Double!,
            ParseClient.JSONBodyKeys.Longitude: studentLocation.longitude as Double!
        ]
        return JSONBody
    }
    
    
}
