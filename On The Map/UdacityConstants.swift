//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Eric Winn on 7/27/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        static let UdacityFacebookAppId: String = "365362206864879"
        static let BaseSecureURL: String = "https://www.udacity.com/"
    }
    
    // MARK: - Methods
    struct Methods {
        static let AccountSignIn = "api/session"
        static let AccountLogOut = "api/session"
        static let AccountSignUp = "account/auth#!/signup"
        static let AccountUserData = "api/users/"
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        static let UserID = "user_id"
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        static let UserName = "username"
        static let Password = "password"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        // General
        static let ErrorMessage = "error"
        static let StatusCode = "status"
        
        // Account
        static let Account = "account"
        static let Registered = "registered"
        static let UserID = "key"
        
        // Session
        static let Session = "session"
        static let SessionID = "id"
        static let SessionExpiration = "expiration"
        
        // User Data
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
    
}