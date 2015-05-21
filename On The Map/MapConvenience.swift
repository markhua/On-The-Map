//
//  MapConvenience.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/21.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit

extension MapClient{
    
    func getStudentLocations(completionHandler: (result: [location]?, error: NSError?)->Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    println(error)
                } else {
                    if let resultArray = parsedResult["results"] as? [[String: AnyObject]]{
                        var locations = location.locationsFromResults(resultArray)
                        completionHandler(result: locations, error: nil)
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "get locations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getlocations"]))
                    }
                    
                }
            }
            
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
    }
}
