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
    
    init(dictionary: [String : AnyObject]) {
        firstname = dictionary["firstName"] as! String
        lastname = dictionary["lastName"] as! String
        maplocation = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    }
    
    static func locationsFromResults(results: [[String : AnyObject]]) -> [location] {
        
        var locations = [location]()
        var duplicate = false
        
        /* Iterate through array of dictionaries; each Movie is a dictionary */
        for result in results {
            for loc in locations {
                if (loc.lastname == result["lastName"] as! String) {
                    duplicate = true
                }
            }
            if (!duplicate){
                locations.append(location(dictionary: result))
            }
            duplicate = false
        }
        
        return locations
    }

    
}
