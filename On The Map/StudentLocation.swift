//
//  StudentLocation.swift
//  On The Map
//
//  Created by Eric Winn on 7/27/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import Foundation
import CoreLocation

// Globally accessible and link custom notification to monitor changes
// ATTRIB: - https://www.andrewcbancroft.com/2014/10/08/fundamentals-of-nsnotificationcenter-in-swift/
// ATTRIB: - http://dev.iachieved.it/iachievedit/nsnotifications-with-userinfo-in-swift/
// ATTRIB: - http://stackoverflow.com/q/24006234
// ATTRIB: - http://www.codingexplorer.com/swift-property-observers/
let StudentLocationNotificationKey = "com.ericnwinn.StudentLocationNotificationKey"
let notificationCenter = NSNotificationCenter.defaultCenter()
var globalStudentLocations = [StudentLocation]() {
    didSet{
        // Notification of change
        notificationCenter.postNotificationName(StudentLocationNotificationKey, object: nil)
    }
}


struct StudentLocation {
    var objectID = ""
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    init () {}
    
    init(dictionary: [String: AnyObject]) {
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double
        createdAt = dictionary[ParseClient.JSONResponseKeys.CreatedAt] as? NSDate
        updatedAt = dictionary[ParseClient.JSONResponseKeys.UpdatedAt] as? NSDate
    }
    
    // Helper: Given an array of dictionaries, convert them to an array of StudentLocation
    static func studentLocationFromResults(results: [[String: AnyObject]]) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
}
