//
//  CustomInputCaloriesAlertViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/22/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CustomInputCaloriesAlertViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var enterCaloriesTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var userId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Grabs the user's ID upon entering the view
        userId = applicationDelegate.userAccountInfo["id"] as! Int
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomInputCaloriesAlertViewController.hideKeyboard(_:)))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)
        
        
        
        submitButton.layer.cornerRadius = 8
        registerForKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Scrolls the scrollview to the bottom so that we can see the buttons
        self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height), animated: true)
    }

    // Allows the keyboard to hide by the user's interaction (background touch)
    func hideKeyboard(sender: UIScrollView)
    {
        scrollView.endEditing(true)
    }
    
    @IBAction func backButtonTapped(sender: UIButton)
    {
        // Close and return to upstream control
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func submitButtonTapped(sender: UIButton)
    {
        var caloriesEntered = enterCaloriesTextField.text!
        
        if caloriesEntered.isEmpty
        {
            caloriesEntered = String(0)
        }
        
        let date: NSDate = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate = cal.startOfDayForDate(date)
        let epochTime = Int(newDate.timeIntervalSince1970)
        print(epochTime)
        
//        //don't forget to import Alamofire and SwiftyJSON
//        
//        //endpoint to database you want to post to
//        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/1461110400"
//        
//        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
//        //Format is = "Field": value
//        let newPost = ["caloriesIn": caloriesEntered, "caloriesOut":200,"logDate":1461110400,"miles":2,"steps":2700,"userId":5,"weight":157]
//        
//        //Creating the request to post the newPost JSON var.
//        Alamofire.request(.PUT, postsEndpoint, parameters: newPost as? [String : AnyObject], encoding: .JSON)
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    // got an error in getting the data, need to handle it
//                    print("error calling GET on /posts/1")
//                    print(response.result.error!)
//                    return
//                }
//                
//                if let value: AnyObject = response.result.value {
//                    // handle the results as JSON, without a bunch of nested if loops
//                    // this might not return anything here, but check the DB just in case. It might post anyway
//                    let post = JSON(value)
//                    print("The post is: " + post.description)
//                }
//        }
//        
       self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
     ---------------------------------------
     MARK: - Handling Keyboard Notifications
     ---------------------------------------
     */
    
    // This method is called in viewDidLoad() to register self for keyboard notifications
    func registerForKeyboardNotifications() {
        
        // "An NSNotificationCenter object (or simply, notification center) provides a
        // mechanism for broadcasting information within a program." [Apple]
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self,
            selector:   #selector(CustomInputCaloriesAlertViewController.keyboardWillShow(_:)),    // <-- Call this method upon Keyboard Will SHOW Notification
            name:       UIKeyboardWillShowNotification,
            object:     nil)
        
        notificationCenter.addObserver(self,
            selector:   #selector(CustomInputCaloriesAlertViewController.keyboardWillHide(_:)),    //  <-- Call this method upon Keyboard Will HIDE Notification
            name:       UIKeyboardWillHideNotification,
            object:     nil)
    }
    
    // This method is called upon Keyboard Will SHOW Notification
    func keyboardWillShow(sender: NSNotification) {
        
        // "userInfo, the user information dictionary stores any additional
        // objects that objects receiving the notification might use." [Apple]
        let info: NSDictionary = sender.userInfo!
        
        /*
         Key     = UIKeyboardFrameBeginUserInfoKey
         Value   = an NSValue object containing a CGRect that identifies the start frame of the keyboard in screen coordinates.
         */
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        
        // Obtain the size of the keyboard
        let keyboardSize: CGSize = value.CGRectValue().size
        
        // Create Edge Insets for the view.
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        
        // Set the distance that the content view is inset from the enclosing scroll view.
        scrollView.contentInset = contentInsets
        
        // Set the distance the scroll indicators are inset from the edge of the scroll view.
        scrollView.scrollIndicatorInsets = contentInsets
        
        //-----------------------------------------------------------------------------------
        // If active text field is hidden by keyboard, scroll the content up so it is visible
        //-----------------------------------------------------------------------------------
        
        // Obtain the frame size of the View
        var selfViewFrameSize: CGRect = self.view.frame
        
        // Subtract the keyboard height from the self's view height
        // and set it as the new height of the self's view
        selfViewFrameSize.size.height -= keyboardSize.height
        
        // Obtain the size of the active UITextField object
        let enterCaloriesTextFieldRect: CGRect? = enterCaloriesTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let enterCaloriesActiveTextFieldOrigin: CGPoint? = enterCaloriesTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, enterCaloriesActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(enterCaloriesTextFieldRect!, animated:true)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        scrollView.scrollEnabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.scrollEnabled = false
    }
    
    // This method is called upon Keyboard Will HIDE Notification
    func keyboardWillHide(sender: NSNotification) {
        
        // Set contentInsets to top=0, left=0, bottom=0, and right=0
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        
        // Set scrollView's contentInsets to top=0, left=0, bottom=0, and right=0
        scrollView.contentInset = contentInsets
        
        // Set scrollView's scrollIndicatorInsets to top=0, left=0, bottom=0, and right=0
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    /*
     ---------------------------------------------
     MARK: - Register and Unregister Notifications
     ---------------------------------------------
     */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
