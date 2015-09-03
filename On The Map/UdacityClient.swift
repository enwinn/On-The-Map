//
//  UdacityClient.swift
//  On The Map
//
//  Created by Eric Winn on 7/27/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    // Shared session
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // 1. Set the parameters: There are none
        
        // 2/3. Build the URL and configure the request
        let urlString = Constants.BaseSecureURL + method
        println("\t\t\tUdacityClient.taskForGETMethod urlString: \(urlString)")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            // 5/6. Parse the data and use the data (happens in completion handler)
            if let error = downloadError {
                println("\t\t\tGot a download error: \(error)")
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        // 7. Start the request
        task.resume()
        
        return task
    }
    
    
    // MARK: - POST
    func taskForPOSTMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // 1. Set the parameters: There are none.
        
        // 2/3. Build the URL and configure the request
        let urlString = Constants.BaseSecureURL + method
        println("UdacityClient.taskForPOSTMethod urlString: \(urlString)")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        if jsonifyError != nil {
            println("jsonifyError: \(jsonifyError)")
        }
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            // 5/6. Parse the data and use the data (happens in completion handler)
            if let error = downloadError {
                println("Got a download error: \(error)")
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        // 7. Start the request
        task.resume()
        
        return task
    }
    
    // MARK: - DELETE
    func taskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // 1. Set the parameters: There are none
        
        // 2/3. Build the URL and configure the request
        let urlString = Constants.BaseSecureURL + method
        println("UdacityClient.taskForDELETEMethod urlString: \(urlString)")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        println("Looping thru cookies...")
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                println("\tFound XSRF-TOKEN cookie: \(cookie)")
                xsrfCookie = cookie
            } else {
                println("\tDid not find an XSRF-TOKEN cookie")
            }
        }
        if let xsrfCookie = xsrfCookie {
            println("Adding X-XSRF-Token header value: \(xsrfCookie.value!)")
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, cookieError in
            
            // 5/6. Parse the data and use the data (happens in completion handler)
            if let error = cookieError {
                println("Got a cookie error: \(error)")
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: cookieError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                println(NSString(data: newData, encoding: NSUTF8StringEncoding)!)
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        // 7. Start the request
        task.resume()
        
        return task
    }
    
    
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            println("substituteKeyInMethod did not find key: \(key)")
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject] {
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.ErrorMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
            }
        }
        return error
    }
    
    /* Helper: Given raw JSON, return a usable foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        if let error = parsingError {
            println("\t\t\t\tGot a JSON parsing error: \(error)")
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }

    // Helper: URLencode querystring parameters
    // ATTRIB: - http://stackoverflow.com/a/27151324
    class func encodeParameters(#params: [String: AnyObject]) -> String {
        var queryItems = map(params) { NSURLQueryItem(name:$0, value:$1 as! String)}
        var components = NSURLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }

}