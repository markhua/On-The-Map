//
//  MapClient.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/21.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import Foundation

class MapClient: NSObject {
    
    var userID : String?
    var sessionID : String?
    var firstName: String?
    var lastName: String?
    var objectid: String?
    var locations : [location] = [location]()
    
    override init(){
        userID = "3929338548"
    }
    
    class func sharedInstance() -> MapClient {
        
        struct Singleton {
            static var sharedInstance = MapClient()
        }
        
        return Singleton.sharedInstance
    }

}
