//
//  MapConvenience.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/21.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import MapKit

extension MapClient{
    
    //Log in users with username and password from LoginViewController, store userid and sessionid in MapClient
    func LoginUdacity(username : String, password : String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        if (username == "") {
            completionHandler(success: false, errorString: "Username is empty")
            return
        }
        if (password == "")
        {
            completionHandler(success: false, errorString: "Password is empty")
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(MapClient.Constants.BaseUdacityURL)session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error...
                completionHandler(success: false, errorString: "Connection Failed")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let error = parsingError {
                    completionHandler(success: false, errorString: "Parsing Error")
            } else {
                //parse userid and sessionid
                if let useraccount = parsedResult["account"] as? NSDictionary {
                    if let userid = useraccount["key"] as? String {
                        self.userID = userid
                        //println("user id: \(self.userID!)")
                        
                        if let session = parsedResult["session"] as? NSDictionary {
                            self.sessionID = session["id"] as? String
                            //println("session id: \(self.sessionID!)")
                            completionHandler(success: true, errorString: nil)

                        } else {
                            completionHandler(success: false, errorString: "Login failed: sessionID")
                        }
                    } else {
                        completionHandler(success: false, errorString: "Login failed: userID")
                    }
                } else {
                    completionHandler(success: false, errorString: "Incorrect username or password")
                }

            }
        }
        task.resume()

    }
    
    //get student locations list and store into the [StudentLocation] array in MapClient
    func getStudentLocations(completionHandler: (success: Bool, error: String?)->Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(MapClient.Constants.BaseParseURL)1/classes/StudentLocation?limit=100")!)
        request.addValue(MapClient.Constants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue(MapClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(success: false, error: "Connection Failed")
                return
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    completionHandler(success: false, error: "Parsing Error")
                } else {
                    if let resultArray = parsedResult["results"] as? [[String: AnyObject]]{
                        var locations = StudentLocation.locationsFromResults(resultArray)
                        self.locations = locations
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: "Could not parse getlocations")
                    }
                    
                }
            }
            
        }
        
        task.resume()
    }
    
    //get the login user's first name and last name, called in AddLocationViewController
    func getUserInfo (completionHandler: (success: Bool, errorString: String?)->Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(MapClient.Constants.BaseUdacityURL)users/\(self.userID!)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error...
                completionHandler(success: false, errorString: "Connection error")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let error = parsingError {
                completionHandler(success: false, errorString: "Parsing Error")
            } else {
                if let useraccount = parsedResult["user"] as? NSDictionary {
                    if let firstname = useraccount["first_name"] as? String {
                        self.firstName = firstname
                        //println("First Name: \(self.firstName!)")
                    }
                    
                    if let lastname = useraccount["last_name"] as? String {
                        self.lastName = lastname
                        //println("Last Name: \(self.lastName!)")
                    }
                        
                    if (self.firstName == "") && (self.lastName == "")
                    {
                        completionHandler(success: false, errorString: "Firstname and lastname are empty")
                    }else{
                        completionHandler(success: true, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, errorString: "Parsing error")
                }
            }
        }
        task.resume()
    }
    
    //post the login student's location with location and media string from AddLocationViewController
    func postUserLocation (location : CLLocationCoordinate2D, LocationString : String, MediaURL : String, completionHandler: (success: Bool, errorString: String?)->Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(MapClient.Constants.BaseParseURL)1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(MapClient.Constants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(MapClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(self.userID!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(LocationString)\", \"mediaURL\": \"\(MediaURL)\",\"latitude\": \(location.latitude), \"longitude\": \(location.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(success: false, errorString: "Connection error")
                return
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    completionHandler(success: false, errorString: "Post error")
                } else {
                    completionHandler(success: true, errorString: nil)
                }
            }
            
        }
        task.resume()
        
    }
    
    //Update a student's location if the student's pin already exists
    func updateUserLocation (location : CLLocationCoordinate2D, LocationString : String, MediaURL : String, completionHandler: (success: Bool, errorString: String?)->Void){
        
        let urlString = "\(MapClient.Constants.BaseParseURL)1/classes/StudentLocation/\(self.objectid!)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "PUT"
        request.addValue(MapClient.Constants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(MapClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(self.userID!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(LocationString)\", \"mediaURL\": \"\(MediaURL)\",\"latitude\": \(location.latitude), \"longitude\": \(location.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(success: false, errorString: "Connection error")
                return
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    completionHandler(success: false, errorString: "Update error")
                } else {
                    completionHandler(success: true, errorString: nil)
                }
            }
            
        }
        
        task.resume()
        
    }
    
    //Validate URL
    func isValidURL(testURL: String) -> Bool {
        let urlregex = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let url = NSPredicate(format: "SELF MATCHES %@", urlregex)
        return (url.evaluateWithObject(testURL))
    }
}
