//
//  LoginViewController.swift
//  On The Map
//
//  Created by Mark Zhang on 15/5/19.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var userID : String?
    var sessionID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonAction(sender: UIButton) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userNameText.text)\", \"password\": \"\(passwordText.text)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error...
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let error = parsingError {
                println(error)
            
            } else {
                if let useraccount = parsedResult["account"] as? NSDictionary {
                    if let userid = useraccount["key"] as? String {
                        self.userID = userid
                        println("user id: \(self.userID!)")
                        
                        if let session = parsedResult["session"] as? NSDictionary {
                            if let sessionid = session["id"] as? String{
                                self.sessionID = sessionid
                                println("session id: \(self.sessionID!)")
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                                    self.presentViewController(controller, animated: true, completion: nil)
                                })
                            } else {
                                println("Login failed: sessionID")
                            }
                        }
                    } else {
                        println("Login failed: userID")
                    }
                }

            }
            //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
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
