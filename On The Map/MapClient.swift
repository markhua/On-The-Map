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
    
    class func sharedInstance() -> MapClient {
        
        struct Singleton {
            static var sharedInstance = MapClient()
        }
        
        return Singleton.sharedInstance
    }

}
