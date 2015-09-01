//
//  ParseConstants.swift
//  On The Map
//
//  Created by Eric Winn on 7/27/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // MARK: - Constants
    struct Constants {
        static let ParseAppId: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRESTAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let BaseSecureURL: String = "https://api.parse.com/"
    }
    
    // MARK: - Methods
    struct Methods {
        static let StudentCollection: String = "1/classes/StudentLocation?"
        static let StudentElement: String = "1/classes/StudentLocation"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        // Parse
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }

    // MARK: - URL Keys
    struct URLKeys {
        static let ObjectID = "objectId"
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        // General
        static let ErrorMessage = "error"
        static let StatusCode = "status"
        static let Results = "results"
        
        // Student Information
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
    

}