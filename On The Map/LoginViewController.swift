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
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var progressIcon: UIActivityIndicatorView!
    @IBOutlet weak var debugText: UILabel!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureUI()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonAction(sender: UIButton) {
        
        self.progressIcon.hidden = false
        self.debugText.hidden = false
        self.debugText.text = "Logging in..."
        
        MapClient.sharedInstance().LoginUdacity(self.userNameText.text, password: self.passwordText.text){ (success, errorString) in
            
            //Navigate to mapview if login is successful, otherwise display error string
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.debugText.text = errorString
                    self.progressIcon.hidden = true
                }
            }
        }
        
    }
    
    @IBAction func signup(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: MapClient.Constants.UdacitySignup)!)
    }
    

}

extension LoginViewController {
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor(red: 1.000, green: 0.5804, blue: 0.1765, alpha: 1.0)
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        userNameText.leftView = emailTextFieldPaddingView
        userNameText.leftViewMode = .Always
        userNameText.textColor = UIColor.whiteColor()
        userNameText.attributedPlaceholder = NSAttributedString(string: userNameText.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        userNameText.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordText.leftView = passwordTextFieldPaddingView
        passwordText.leftViewMode = .Always
        passwordText.textColor = UIColor.whiteColor()
        passwordText.attributedPlaceholder = NSAttributedString(string: passwordText.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordText.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
}

/* code to adjust view to keyboard */
extension LoginViewController {
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

