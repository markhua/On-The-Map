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

    var annotations : [MKPointAnnotation] = [MKPointAnnotation]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Add Logout and refresh button on the navigation bar
        let logoutbutton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
        let refreshbutton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshMap:")
        self.navigationItem.setLeftBarButtonItems([logoutbutton, refreshbutton], animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadMap()
    }
    
    //Refresh location data
    func refreshMap(sender: UIBarButtonItem) {
        self.mapView.removeAnnotations(self.annotations)
        loadMap()
    }
    
    //Creat an array of annotations from students' locations and add to map
    func loadMap() {
        
        MapClient.sharedInstance().getStudentLocations {success, error in
            if success {
                for location in MapClient.sharedInstance().locations {
                    var Annotation = MKPointAnnotation()
                    Annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                    Annotation.title = "\(location.firstname) \(location.lastname)"
                    Annotation.subtitle = location.mediaURL
                    self.annotations.append(Annotation)
                    dispatch_async(dispatch_get_main_queue()){
                        self.mapView.addAnnotation(Annotation)
                    }
                }
            }else{
                self.notificationmsg(error!)
            }
            
        }
    }
    
    //user logout
    func logout(sender: UIBarButtonItem) {
        MapClient.sharedInstance().userID = ""
        MapClient.sharedInstance().sessionID = ""
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginview") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }

    //Add information button to each pin
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
    
    //Open the URL in browser after tapping the annotation
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!){
        var url = view.annotation.subtitle!
        if let checkURL = NSURL(string: url) {
            if (!UIApplication.sharedApplication().openURL(checkURL)){
                notificationmsg("Invalid URL")
            }
        }
    }
    
    //Display notification with message string
    func notificationmsg (msgstring: String)
    {
        dispatch_async(dispatch_get_main_queue()){
            let controller = UIAlertController(title: "Notification", message: msgstring, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }


}
