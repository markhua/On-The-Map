//
//  ViewController.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/19.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit


class StudentLocationViewController: UITableViewController, UITableViewDataSource {
    
    @IBOutlet var locationTable: UITableView!

    var locations : [location] = [location]()
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MapClient.sharedInstance().getStudentLocations {locs, error in
            if let locs = locs {
                self.locations = locs
                dispatch_async(dispatch_get_main_queue()){
                    self.locationTable.reloadData()
                }
            }else{
                dispatch_async(dispatch_get_main_queue()){
                    let controller = UIAlertController(title: "Alert", message: error, preferredStyle: .Alert)
                    controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
            
        }

    }
    
    @IBAction func refreshTable(sender: UIBarButtonItem) {
        self.viewDidLoad()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "LocationTableViewCell"
        let location = locations[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(location.firstname) \(location.lastname)"
        cell.imageView!.image = UIImage(named: "Pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Push the movie detail view */
        let currentlocation = locations[indexPath.row]
        if let checkURL = NSURL(string: currentlocation.mediaURL) {
            if (!UIApplication.sharedApplication().openURL(checkURL)){
                dispatch_async(dispatch_get_main_queue()){
                    let controller = UIAlertController(title: "Alert", message: "Invalid URL", preferredStyle: .Alert)
                    controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }

}

