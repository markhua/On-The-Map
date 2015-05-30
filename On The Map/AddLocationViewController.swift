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
        
        //display activity indicator
        progressIcon.hidden = false
        SearchingText.hidden = false
        
        //geocode the location string and add pin to the map
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
                self.notificationmsg(error.localizedDescription)
            }
        
        })
        
        
    }
    
    
    @IBAction func submitLocation(sender: UIButton) {
        
        self.progressIcon.hidden = false
        self.SearchingText.text = "Posting location..."
        self.SearchingText.hidden = false
        self.mapView.alpha = 0.5
        var userpinexist = false
     
        //Get user's firstname and lastname by calling getUserInfo
        MapClient.sharedInstance().getUserInfo { success, error in
            if success {
                
                //check if the input URL is valid or not
                
                if MapClient.sharedInstance().isValidURL(self.urlView.text) {
                    if let checkURL = NSURL(string: self.urlView.text) {

                        //get all students' locations and check whether the user's pin already exists
                        MapClient.sharedInstance().getStudentLocations {success, error in
                            if success {
                                outerloop: for location in MapClient.sharedInstance().locations{
                                    if location.uniqueKey == MapClient.sharedInstance().userID {
                                        userpinexist = true
                                        MapClient.sharedInstance().objectid = location.objectid
                                        break outerloop
                                    }
                                }
                                var urlstring = self.urlView.text
                                
                                //if the user already has a pin, ask whether to update existing pin
                                if(userpinexist){
                                    dispatch_async(dispatch_get_main_queue()){
                                        let controller = UIAlertController(title: "Notification", message: "\(MapClient.sharedInstance().firstName!) \(MapClient.sharedInstance().lastName!), you already have a pin, do you want to update it?", preferredStyle: .Alert)
                                        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                                            self.mapView.alpha = 1
                                            self.SearchingText.hidden = true
                                            self.progressIcon.hidden = true
                                            self.SearchingText.text = "Searching..."
                                        }
                                        let updateAction: UIAlertAction = UIAlertAction(title: "Update", style: .Default) { action -> Void in
                                            
                                            //Call updateUserLocation to update location
                                            MapClient.sharedInstance().updateUserLocation(self.location!, LocationString: self.locationView.text, MediaURL: urlstring){ success, error in
                                                if success {
                                                    dispatch_async(dispatch_get_main_queue()){
                                                        let controller = UIAlertController(title: "Notification", message: "Update location success", preferredStyle: .Alert)
                                                        controller.addAction(UIAlertAction(title: "OK", style: .Default) {
                                                            action -> Void in
                                                                self.dismissViewControllerAnimated(true, completion: nil)
                                                            })
                                                        self.presentViewController(controller, animated: true, completion: nil)
                                                    }
                                                } else {
                                                    self.notificationmsg(error!)
                                                }
                                            }
                                        }
                                        controller.addAction(updateAction)
                                        controller.addAction(cancelAction)
                                        self.presentViewController(controller, animated: true, completion: nil)
                                    }
                                    
                                } else {
                                    
                                    //Add a new pin for the user
                                    MapClient.sharedInstance().postUserLocation(self.location!, LocationString: self.locationView.text, MediaURL: self.urlView.text){ success, error in
                                        if success {
                                            dispatch_async(dispatch_get_main_queue()){
                                                let controller = UIAlertController(title: "Notification", message: "Post location success", preferredStyle: .Alert)
                                                controller.addAction(UIAlertAction(title: "OK", style: .Default) {
                                                    action -> Void in
                                                    self.dismissViewControllerAnimated(true, completion: nil)
                                                    })
                                                self.presentViewController(controller, animated: true, completion: nil)
                                            }
                                        } else {
                                            self.notificationmsg(error!)
                                        }
                                    }
                                    
                                }
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

        }

    }
    
    //Display notification with message string
    func notificationmsg (msgstring: String)
    {
        dispatch_async(dispatch_get_main_queue()){
            self.mapView.alpha = 1
            self.SearchingText.hidden = true
            self.progressIcon.hidden = true
            self.SearchingText.text = "Searching..."
            let controller = UIAlertController(title: "Notification", message: msgstring, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissViewController(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Clear the textview when start editing
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        textView.text = ""
        return true
    }
    
    //Dismiss keyboard after return
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String)-> Bool{
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    

}
