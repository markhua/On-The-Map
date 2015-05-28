//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/23.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var urlView: UITextView!
    @IBOutlet weak var locationView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var progressIcon: UIActivityIndicatorView!
    @IBOutlet weak var SearchingText: UILabel!
    
    let locationManager = CLLocationManager()
    var location : CLLocationCoordinate2D?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchButton.layer.cornerRadius = 10
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.whiteColor().CGColor

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        urlView.delegate = self
        locationView.delegate = self
        
        progressIcon.hidden = true
        SearchingText.hidden = true
    }

    @IBAction func SearchLocation(sender: UIButton) {
        
        progressIcon.hidden = false
        SearchingText.hidden = false
        
        CLGeocoder().geocodeAddressString(self.locationView.text, completionHandler: {(placemarks, error)->Void in
            if error == nil {
                let placemark = placemarks[0] as! CLPlacemark
                var annotation = MKPointAnnotation()
                
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.02, 0.02)
                self.location = placemark.location.coordinate
                let region: MKCoordinateRegion = MKCoordinateRegionMake(self.location!, span)
                
                annotation.coordinate = self.location!
                annotation.title = placemark.name
                
                self.progressIcon.hidden = true
                self.SearchingText.hidden = true
                
                self.mapView.hidden = false
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(annotation)
                self.submitButton.hidden = false
                self.searchButton.hidden = true
                self.locationView.hidden = true
                self.urlView.editable = true

                
            } else {
                //println(error)
                self.progressIcon.hidden = true
                self.SearchingText.hidden = true
                self.notificationmsg(error.localizedDescription)
            }
        
        })
        
        
    }
    
    
    @IBAction func submitLocation(sender: UIButton) {
        
        self.progressIcon.hidden = false
        self.SearchingText.text = "Posting location..."
        self.SearchingText.hidden = false
        self.mapView.alpha = 0.5
        
        
        MapClient.sharedInstance().getUserInfo { success, error in
            if success {
                if let checkURL = NSURL(string: self.urlView.text) {
                    if UIApplication.sharedApplication().canOpenURL(checkURL)  {
                        MapClient.sharedInstance().postUserLocation(self.location!, LocationString: self.locationView.text, MediaURL: self.urlView.text){ success, error in
                            if success {
                                println("success")
                                dispatch_async(dispatch_get_main_queue()){
                                    self.notificationmsg("Post location success")
                                }
                            } else {
                                self.notificationmsg(error!)
                            }
                        }
                    }else{
                        self.notificationmsg("invalid url")
                    }
                    
                }else{
                    self.notificationmsg("invalid url")
                }
            } else {
                self.notificationmsg(error!)
            }
            self.SearchingText.text = "Searching..."
        }

   

    }

    func notificationmsg (msgstring: String)
    {
        self.mapView.alpha = 1
        self.SearchingText.hidden = true
        self.progressIcon.hidden = true
        
        dispatch_async(dispatch_get_main_queue()){
            let controller = UIAlertController(title: "Notification", message: msgstring,     preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissViewController(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String)-> Bool{
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
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
