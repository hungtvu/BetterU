//
//  SignInViewController.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignInViewController: UIViewController {

    var items = [UserObject]()
    
    // Initializing and making object references to the UITextField class
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    // Initializing and making object references to the UIButton class
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var checkBoxButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    
    // Action call for the checkBoxButton
    // When the check box button is touched, the states of the checkbox images will change
    @IBAction func checkBoxButtonTapped(sender: UIButton)
    {
        
    }
    
    
    // This method gets called first when the view is shown
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adding in rounded corners to the buttons
        loginButton.layer.cornerRadius = 8;
        signupButton.layer.cornerRadius = 8;
        facebookButton.layer.cornerRadius = 8;
        //updateIP()
        
        
        
    }
    
    //MARK: - REST calls
    // This makes the GET call to httpbin.org. It simply gets the IP address and displays it on the screen.
    func updateIP() {
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let postEndpoint: String = "http://jupiter.cs.vt.edu/BetterUREST-1.0/webresources/com.mycompany.betterurest.user"
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                if let ipString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                    // Print what we got from the call
                    print(ipString)
                    
                    // Parse the JSON to get the IP
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let origin = jsonDictionary["users"] as! NSDictionary
                    
                    // Update the label
                    self.performSelectorOnMainThread(#selector(SignInViewController.updateIPLabel(_:)), withObject: origin, waitUntilDone: false)
                }
            } catch {
                print("bad things happened")
            }
        }).resume()
    }
    
    
    func postDataToURL() {
        
        // Setup the session to make REST POST call
        let postEndpoint: String = "http://jupiter.cs.vt.edu/BetterUREST-1.0/webresources/com.mycompany.betterurest.user"
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        let postParams : [String: AnyObject] = ["hello": "Hello POST world"]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print(postParams)
        } catch {
            print("bad things happened")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            if let postString = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                // Print what we got from the call
                print("POST: " + postString)
                self.performSelectorOnMainThread(#selector(SignInViewController.updatePostLabel(_:)), withObject: postString, waitUntilDone: false)
            }
            
        }).resume()
    }
    
    //MARK: - Methods to update the UI immediately
    func updateIPLabel(text: String) {
        print("Your IP is " + text)
    }
    
    func updatePostLabel(text: String) {
        print("POST : " + text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     ---------------------------------
     MARK: - Keyboard Handling Methods
     ---------------------------------
     */
    
    // This method is invoked when the user taps the Done key on the keyboard
    @IBAction func keyboardDone(sender: UITextField) {
        
        // Once the text field is no longer the first responder, the keyboard is removed
        sender.resignFirstResponder()
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /*
         "A UITouch object represents the presence or movement of a finger on the screen for a particular event." [Apple]
         We store the UITouch object's unique ID into the local variable touch.
         */
        if let touch = touches.first {
            /*
             When the user taps within a text field, that text field becomes the first responder.
             When a text field becomes the first responder, the system automatically displays the keyboard.
             */
            
            // If usernameTextField is first responder and the user did not touch the usernameTextField
            if usernameTextField.isFirstResponder() && (touch.view != usernameTextField) {
                
                // Make usernameTextField to be no longer the first responder.
                usernameTextField.resignFirstResponder()
            }
            
            if passwordTextField.isFirstResponder() && (touch.view != passwordTextField) {
                
                // Make passwordTextField to be no longer the first responder.
                passwordTextField.resignFirstResponder()
            }
            
            
            
        }
        super.touchesBegan(touches, withEvent:event)
    }

}
