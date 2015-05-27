//
//  Location.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/21.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

struct location {
    
    var firstname = ""
    var lastname = ""
    var maplocation = ""
    var mediaURL = ""
    var latitude = 1.0
    var longitude = 1.0
    var uniqueKey = ""
    
    init(dictionary: [String : AnyObject]) {
        firstname = dictionary["firstName"] as! String
        lastname = dictionary["lastName"] as! String
        maplocation = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        uniqueKey = dictionary["uniqueKey"] as! String
    }
    
    static func locationsFromResults(results: [[String : AnyObject]]) -> [location] {
        
        var locations = [location]()
        var duplicate = false
        
        //Add each location from results to array without duplication
        for result in results {
            if let uniqueKey = result["uniqueKey"] as? String {
                    outerLoop: for loc in locations {
                        
                        //Use uniqueKey to identify duplicates
                        if loc.uniqueKey == uniqueKey {
                            duplicate = true
                            println("duplicate")
                            break outerLoop
                        }
                    }
                    if (!duplicate){
                        locations.append(location(dictionary: result))
                    }
            }else{
                println("uniqueKey is empty")
            }
            duplicate = false
        }
        
        return locations
    }

    
}
