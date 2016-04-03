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
    
    // Initialize variables to store JSON data
    var username: String = ""
    var password: String = ""
    var usernameAndPasswordDict = [String: String]()
    var userWeightDict = [String: Int]()
    var weight: Int = 0
    
    var isLoggedIn = false
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
        
        parseJSONForUserAccountAuthorization()
    }
    
    // This method calls from BetterU's REST API and parses its JSON information.
    func parseJSONForUserAccountAuthorization()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user"
        
        // Convert URL to NSURL
        let url = NSURL(string: restApiUrl)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError
        {
            print("Error in retrieving JSON data: \(error.localizedDescription)")
            return
        }
        
        if let jsonDataFromApiURL = jsonData
        {
            // The JSON data is successfully obtained from the API
            
            /*
             NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
             NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
             */
            
            do
            {
                // Grabs all of the JSON data info as an array. NOTE, this stores ALL of the info, it does NOT have
                // any info from inside of the JSON.
                
                /* {
                 DCSkipped = 1;
                 WCSkipped = 1;
                 activityGoal = "Very Active";
                 activityLevel = 0;
                 age = 20;
                 bmr = 1724;
                 dailyChallengeIndex = 4;
                 email = "jdoe@vt.edu";
                 firstName = John;
                 gender = M;
                 goalType = 4;
                 goalWeight = 130;
                 height = 65;
                 id = 1;
                 lastName = Doe;
                 password = password;
                 points = 0;
                 securityAnswer = Virginia;
                 securityQuestion = 3;
                 units = I;
                 username = jdoe;
                 weeklyChallengeIndex = 2;
                 weight = 155;
                 },
                 */
                let jsonDataArray = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                
                var jsonDataDictInfo: NSDictionary = NSDictionary()
                
                var i = 0
                while (i < jsonDataArray.count)
                {
                    jsonDataDictInfo = jsonDataArray[i] as! NSDictionary
                    
                    // Grabs data from the JSON and stores it into the appropriate variable
                    username = jsonDataDictInfo["username"] as! String
                    password = jsonDataDictInfo["password"] as! String
                    weight = jsonDataDictInfo["weight"] as! Int
                    
                    // Password is value, username is key
                    usernameAndPasswordDict[username] = password
                    
                    // Weight is value, username is key
                    userWeightDict[username] = weight
                    
                    i += 1
                    
                }

            }catch let error as NSError
            {
                print("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
        }
            
        else
        {
            print("Error in retrieving JSON data!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // User authenication and authorization.
    @IBAction func loginButtonTapped(sender: UIButton)
    {
        let usernameEntered = usernameTextField.text
        let passwordEntered = passwordTextField.text
        
        if ((usernameEntered ?? "").isEmpty || (passwordEntered ?? "").isEmpty)
        {
            showAlertViewControllers("Sign in Failed!", errorMessage: "Please enter your username and password!")
        }
        
        // User authentication: Checks to see if the dictionary has the key-value pair. If it does, then grab the value 
        // as password and checks to see if the user enters the value to the key correctly.
        if let passwordValue = usernameAndPasswordDict[usernameEntered!]
        {
            if (passwordValue == passwordEntered)
            {
                if let weightValue = userWeightDict[usernameEntered!]
                {
                    // Assign value to variable to pass downstream
                    weight = weightValue
                }
                
               
                // Create a new ingredient title name with a new title in the plist
                applicationDelegate.userAccountInfo.setObject(weight, forKey: "User Weight")
                applicationDelegate.userAccountInfo.setObject(usernameEntered!, forKey: "Username")
                applicationDelegate.userAccountInfo.setObject(passwordEntered!, forKey: "Password")
                
                
                isLoggedIn = true
                self.performSegueWithIdentifier("homeView", sender: self);
            }
            
            // password is not entered in correctly.
            else
            {
                showAlertViewControllers("Sign in Failed!", errorMessage: "Password entered is incorrect.")
                
            }
        }
        
        // Username is not entered in correctly.
        else
        {
            showAlertViewControllers("Sign in Failed!", errorMessage: "Username entered is incorrect.")
            
        }
        
        isLoggedIn = false
    }
    
    /*
        This method uses UIAlertController class to show a dialog box upon user interaction.
    */
    func showAlertViewControllers(titleOfError: String, errorMessage: String)
    {
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: titleOfError, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        // Present the alert controller by calling the presentViewController method
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     */
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
//    {
//        if segue.identifier == "homeView" {
//            
//            let tabBarController = segue.destinationViewController as! CustomTabBarController
//            
//            // Grabs the story board
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//            // In order to segue between view controllers that have no connection, we must use the unique Storyboard ID
//            // We must then go through the navigation controller first before reaching the actual view controller
//            let navigationController = storyboard.instantiateViewControllerWithIdentifier("Home") as! UINavigationController
//            
//            //let navigationController = tabBarController.viewControllers![0] as! UINavigationController
//        
//            // Use the navigation controller to reach the table view controller
//            let homeTableViewController = navigationController.viewControllers.first as! HomeTableViewController
//            
//            // Passing information downstream
//            homeTableViewController.weightInLbs = weight
//            
//            //self.presentViewController(navigationController, animated: true, completion: nil)
//            
//        }
//        
//    }
    
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
