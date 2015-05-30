//
//  Location.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/21.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

struct StudentLocation {
    
    var firstname = ""
    var lastname = ""
    var maplocation = ""
    var mediaURL = ""
    var latitude = 1.0
    var longitude = 1.0
    var uniqueKey = ""
    var objectid = ""
    
    init(dictionary: [String : AnyObject]) {
        if let FirstName = dictionary["firstName"] as? String { firstname = FirstName }
        if let Lastname = dictionary["lastName"] as? String {lastname = Lastname }
        if let Maplocation = dictionary["mapString"] as? String {maplocation = Maplocation}
        if let MediaURL = dictionary["mediaURL"] as? String {mediaURL = MediaURL}
        if let Latitude = dictionary["latitude"] as? Double {latitude = Latitude}
        if let Longitude = dictionary["longitude"] as? Double {longitude = Longitude}
        if let UniqueKey = dictionary["uniqueKey"] as? String {uniqueKey = UniqueKey}
        if let Objectid = dictionary["objectId"] as? String {objectid = Objectid}
    }
    
    //Add each location from results to array without duplication
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
        
        var locations = [StudentLocation]()
        var duplicate = false
        
        for result in results {
            if let uniqueKey = result["uniqueKey"] as? String {
                    outerLoop: for loc in locations {
                        
                        //Use uniqueKey to identify duplicates
                        if loc.uniqueKey == uniqueKey {
                            duplicate = true
                            break outerLoop
                        }
                    }
                    if (!duplicate){
                        locations.append(StudentLocation(dictionary: result))
                    }
            }else{
                println("uniqueKey is empty")
            }
            duplicate = false
        }
        
        return locations
    }

    
}
