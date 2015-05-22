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
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Sun Yat-sen University"
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse!, error: NSError!) in
        
            if error != nil {
                println("Error occured in search: \(error.localizedDescription)")
            }else if(response.mapItems.count == 0) {
                println("No matches found")
            }else {
                println("Matches Found")
                let items = response.mapItems as! [MKMapItem]
                
                var annotation = MKPointAnnotation()
                annotation.coordinate = items[0].placemark.coordinate
                annotation.title = items[0].name
                
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                let location: CLLocationCoordinate2D = annotation.coordinate
                let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                
                self.mapView.setRegion(region, animated: true)
                
                self.mapView.addAnnotation(annotation)
                
                
                
                /*for item in response.mapItems as![MKMapItem] {
                    println("Name = \(item.name)")
                }*/

            }
        
        })
        
        // Do any additional setup after loading the view.
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
