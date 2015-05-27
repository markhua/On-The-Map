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
        mapView.delegate = self
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
                let controller = UIAlertController(title: "Alert", message: error, preferredStyle: .Alert)
                controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
        }
        
        // Do any additional setup after loading the view.
    }

    func mapView(mapView:MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView {
        let identifier = "MapLocation"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            
            let btn = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            annotationView.rightCalloutAccessoryView = btn
        }else {
            annotationView.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!){
        var url = view.annotation.subtitle!
        if let checkURL = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(checkURL)
        }else
        {
            println("invalid url")
        }
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
