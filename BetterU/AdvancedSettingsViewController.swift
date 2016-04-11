//
//  AdvancedSettingsViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/4/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AdvancedSettingsViewController: UIViewController, UITextFieldDelegate {

    // Initialize objects onto the view controller
    @IBOutlet var goalWeightTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var confirmNewPasswordTextField: UITextField!
    @IBOutlet var settingsTableView: UITableView!
    @IBOutlet var saveButton: UIButton!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Initialize variables that are needed to update from textfields
    var email = ""
    var firstName = ""
    var lastName = ""
    var age = 0
    var height = 0
    var weight = 0
    var gender = ""
    var heightFtCalculated = 0
    var heightInCalculated = 0
    
    // Initialize variables that are NOT needed to update from textfields. These, however, are required
    // to post back the accurate data that was unchanged to the backend database
    var activityGoal = ""
    var currentActivityLevel = 0
    var exp = 0
    var goalWeight = 0
    var id = 0
    var password = ""
    var username = ""
    var securityQuestion = 0
    var securityAnswer = ""
    
    var heightInches = ""
    var heightFt = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.layer.cornerRadius = 8
        
        
        
        // Grabbing variables from the plist
        email = applicationDelegate.userAccountInfo["Email"] as! String
        firstName = applicationDelegate.userAccountInfo["First Name"] as! String
        lastName = applicationDelegate.userAccountInfo["Last Name"] as! String
        age = applicationDelegate.userAccountInfo["Age"] as! Int
        height = applicationDelegate.userAccountInfo["Height"] as! Int
        weight = applicationDelegate.userAccountInfo["User Weight"] as! Int
        gender = applicationDelegate.userAccountInfo["Gender"] as! String
        
        activityGoal = applicationDelegate.userAccountInfo["Activity Goal"] as! String
        currentActivityLevel = applicationDelegate.userAccountInfo["Current Activity Level"] as! Int
        exp = applicationDelegate.userAccountInfo["Exp"] as! Int
        goalWeight = applicationDelegate.userAccountInfo["Goal Weight"] as! Int
        id = applicationDelegate.userAccountInfo["id"] as! Int
        password = applicationDelegate.userAccountInfo["Password"] as! String
        username = applicationDelegate.userAccountInfo["Username"] as! String
        securityQuestion = applicationDelegate.userAccountInfo["Security Question"] as! Int
        securityAnswer = applicationDelegate.userAccountInfo["Security Answer"] as! String
        
        emailTextField!.text = email
        goalWeightTextField!.text = String(goalWeight)
        newPasswordTextField!.text = password
        confirmNewPasswordTextField!.text = password
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        parseJson()
        
        emailTextField!.text = email
        goalWeightTextField!.text = String(goalWeight)
        newPasswordTextField!.text = password
        confirmNewPasswordTextField!.text = password
    }

    func parseJson()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/\(id)"
        
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
                let jsonDataDictInfo = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                // Grabs data from the JSON and stores it into the appropriate variable
                username = jsonDataDictInfo["username"] as! String
                password = jsonDataDictInfo["password"] as! String
                weight = jsonDataDictInfo["weight"] as! Int
                firstName = jsonDataDictInfo["firstName"] as! String
                lastName = jsonDataDictInfo["lastName"] as! String
                email = jsonDataDictInfo["email"] as! String
                age = jsonDataDictInfo["age"] as! Int
                gender = jsonDataDictInfo["gender"] as! String
                height = jsonDataDictInfo["height"] as! Int
                exp = jsonDataDictInfo["points"] as! Int
                currentActivityLevel = jsonDataDictInfo["activityLevel"] as! Int
                activityGoal = jsonDataDictInfo["activityGoal"] as! String
                goalWeight = jsonDataDictInfo["goalWeight"] as! Int
                id = jsonDataDictInfo["id"] as! Int
                securityQuestion = jsonDataDictInfo["securityQuestion"] as! Int
                securityAnswer = jsonDataDictInfo["securityAnswer"] as! String
                
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

    
    @IBAction func saveButtonTapped(sender: UIButton)
    {
        
        var emailToUse = ""
        var goalWeightToUse = ""
        var newPasswordToUse = ""
        
        // if the user has changed their email
        if emailTextField!.text != email
        {
            emailToUse = emailTextField!.text!
        }
        
        else
        {
            emailToUse = email
        }
        
        // If the user has changed their goal weight
        if goalWeightTextField!.text != String(goalWeight)
        {
            goalWeightToUse = goalWeightTextField!.text!
        }
        
        else
        {
            goalWeightToUse = String(goalWeight)
        }
        
        // If the user decides to change to a new password
        if newPasswordTextField!.text != password
        {
            if newPasswordTextField!.text?.characters.count < 8
            {
                self.showErrorMessage("Please enter a password that has a minimum of 8 characters.", errorTitle: "Password Length too Short!")
                return
            }
            
            if newPasswordTextField!.text != confirmNewPasswordTextField!.text
            {
                self.showErrorMessage("Please enter the correct password confirmation.", errorTitle: "Password Mismatch!")
                return
            }
            
            newPasswordToUse = newPasswordTextField!.text!
        }
        else
        {
            newPasswordToUse = password
        }
        
        //don't forget to import Alamofire and SwiftyJSON
        
        //endpoint to database you want to post to
        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/\(id)"
        
        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
        //Format is = "Field": value
        let newPost = ["DCSkipped": 0, "WCSkipped": 0, "activityGoal": activityGoal, "activityLevel": currentActivityLevel, "age": age, "bmr": "testBMR", "dailyChallengeIndex": 0, "email": emailToUse, "firstName": firstName, "gender": gender, "goalType": 0, "goalWeight": goalWeightToUse, "height": height, "id": id, "lastName": lastName, "password": newPasswordToUse, "points": 0, "securityAnswer": securityAnswer, "securityQuestion": securityQuestion, "targetCalories": 0, "units": "I", "username": username, "weeklyChallengeIndex": 0, "weight": weight]
        
        //Creating the request to post the newPost JSON var.
        Alamofire.request(.PUT, postsEndpoint, parameters: newPost as? [String : AnyObject], encoding: .JSON)
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /posts/1")
                    print(response.result.error!)
                    return
                }
                
                if let value: AnyObject = response.result.value {
                    // handle the results as JSON, without a bunch of nested if loops
                    // this might not return anything here, but check the DB just in case. It might post anyway
                    let post = JSON(value)
                    print("The post is: " + post.description)
                }
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    
    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    
    // We are implementing a Grouped table view style as we selected in the storyboard file.
    
    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    
    // Each table view section corresponds to a country
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    //---------------------------------
    // Return Number of Rows in Section
    //---------------------------------
    
    // Number of rows in a given country (section) = Number of Cities in the given country (section)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let row = indexPath.row
        
        if row == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("pushNotifCell") as! PushNotificationTableViewCell
            
            cell.titleLabel!.text = "Push Notification"
            
            return cell
        }
        
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("setActLvlCell")! as UITableViewCell
            
            cell.textLabel!.text = "Set Activity Level"
            
            return cell
        }
        
    }
    
    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */
    
    //-------------------
    // Selection of a Row
    //-------------------
    
    // Tapping a row displays another view
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let row = indexPath.row
        
        if row == 1
        {
            performSegueWithIdentifier("setActivityLevel", sender: self)
        }
    }

    
    /*
     ----------------------------------------------------------
     MARK: - Allows the textfield to have a max of 5 characters
     ----------------------------------------------------------
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 3
        }
        return true
    }
    
    // This method is called when the user taps Return on the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Deactivate the text field and remove the keyboard
        textField.resignFirstResponder()
        
        return true
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
            
            // If goalWeightTextField is first responder and the user did not touch the goalWeightTextField
            if goalWeightTextField.isFirstResponder() && (touch.view != goalWeightTextField) {
                
                // Make goalWeightTextField to be no longer the first responder.
                goalWeightTextField.resignFirstResponder()
            }
            
            if emailTextField.isFirstResponder() && (touch.view != emailTextField) {
                
                // Make emailTextField to be no longer the first responder.
                emailTextField.resignFirstResponder()
            }
            
            if newPasswordTextField.isFirstResponder() && (touch.view != newPasswordTextField) {
                
                // Make newPasswordTextField to be no longer the first responder.
                newPasswordTextField.resignFirstResponder()
            }
            
            if confirmNewPasswordTextField.isFirstResponder() && (touch.view != confirmNewPasswordTextField) {
                
                // Make confirmNewPasswordTextField to be no longer the first responder.
                confirmNewPasswordTextField.resignFirstResponder()
            }
            
            
            
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
   
    
    /*
     ------------------------------------------------
     MARK: - Show Alert View Displaying Error Message
     ------------------------------------------------
     */
    func showErrorMessage(errorMessage: String, errorTitle: String) {
        dispatch_async(dispatch_get_main_queue())
        { () -> Void in
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local constant alertController
             */
            let alertController = UIAlertController(title: errorTitle, message: errorMessage,
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }

}
