//
//  MapViewController.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/21.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    var locations : [location] = [location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapClient.sharedInstance().getStudentLocations {locs, error in
            if let locs = locs {
                self.locations = locs
                for location in self.locations {
                    var Annotation = MKPointAnnotation()
                    Annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                    Annotation.title = "\(location.firstname) \(location.lastname)"
                    Annotation.subtitle = location.mediaURL
                    dispatch_async(dispatch_get_main_queue()){
                        self.mapView.addAnnotation(Annotation)
                    }
                }
            }else{
                println(error)
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    @IBAction func AddLocation(sender: UIBarButtonItem) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
