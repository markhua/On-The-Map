//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/23.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var locationView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    var location : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SearchLocation(sender: UIButton) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationView.text
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
                self.location = annotation.coordinate
                let region: MKCoordinateRegion = MKCoordinateRegionMake(self.location!, span)
                
                self.mapView.hidden = false
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(annotation)
                self.submitButton.hidden = false
                
                /*for item in response.mapItems as![MKMapItem] {
                println("Name = \(item.name)")
                }*/
                
            }
            
        })
    }
    
    
    @IBAction func submitLocation(sender: UIButton) {
        
        if let loc = self.location
        {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
            request.HTTPMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"uniqueKey\": \"3929338548\", \"firstName\": \"Huazhi\", \"lastName\": \"Zhang\",\"mapString\": \"\(self.locationView.text)\", \"mediaURL\": \"https://udacity.com\",\"latitude\": \(loc.latitude), \"longitude\": \(loc.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error...
                    return
                } else {
                    var parsingError: NSError? = nil
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                    if let error = parsingError {
                        println(error)
                    } else {
                        println(parsedResult)
                    }
                }
            
            }
        task.resume()
            
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
