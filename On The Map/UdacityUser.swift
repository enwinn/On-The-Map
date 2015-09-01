//
//  UdacityUser.swift
//  On The Map
//
//  Created by Eric Winn on 8/25/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import Foundation

var udacityUser = UdacityUser()

struct UdacityUser {
    
    var firstName = ""
    var LastName = ""
    var userID = ""
    var objectID = ""
    var mapString = ""
    var mediaURL = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    var createdAt = ""
    var updatedAt = ""
    var hasPosting = false
    
    mutating func setUdacityUser(firstName: String, lastName: String, userID: String) {
        println("\t\t\tsetUdacityUser with firstname: \(firstName), lastName: \(lastName), userID: \(userID)")
        self.firstName = firstName
        self.LastName = lastName
        self.userID = userID
    }
    
    // Set at initial location pin creation or when the map view is loaded and a logged on user pin/location record is found
    mutating func setStudentLocation(hasPosting: Bool, objectID: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, createdAt: String, updatedAt: String) {
        println("\t\t\tsetStudentLocation with hasPosting: \(hasPosting), objectID: \(objectID)")
        self.hasPosting = hasPosting
        self.objectID = objectID
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
}
