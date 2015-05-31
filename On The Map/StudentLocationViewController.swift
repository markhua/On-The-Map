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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Add Logout and refresh button on the navigation bar
        let logoutbutton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
        let refreshbutton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshTable:")
        self.navigationItem.setLeftBarButtonItems([logoutbutton, refreshbutton], animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get locations and load to the tableview
        refreshData()

    }
    
    //Refresh location data
    @IBAction func refreshTable(sender: UIBarButtonItem) {
        refreshData()
    }
    
    func refreshData () {
        MapClient.sharedInstance().getStudentLocations {success, error in
            if success {
                let locs = MapClient.sharedInstance().locations
                dispatch_async(dispatch_get_main_queue()){
                    self.locationTable.reloadData()
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "LocationTableViewCell"
        let location = MapClient.sharedInstance().locations[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(location.firstname) \(location.lastname)"
        cell.imageView!.image = UIImage(named: "Pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapClient.sharedInstance().locations.count
    }
    
   //Open student's URL in browser after clicking each cell
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        let currentlocation = MapClient.sharedInstance().locations[indexPath.row]
        if let checkURL = NSURL(string: currentlocation.mediaURL) {
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

