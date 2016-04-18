//
//  SignInViewController.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignInViewController: UIViewController, UITextFieldDelegate {
    
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
    var weight: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var age: Int = 0
    var height: Int = 0
    var gender: String = ""
    var levelExp: Int = 0
    var activityGoal = ""
    var activityLevel = 0
    var goalWeight = 0
    var userId = 0
    var securityQuestion = 0
    var securityAnswer = ""
    
    // Dictionary KV pairs for the JSON data variables
    var usernameAndPasswordDict = [String: String]()
    var userWeightDict = [String: Int]()
    var username_Dict_firstName = [String: String]()
    var username_Dict_lastName = [String: String]()
    var username_Dict_email = [String: String]()
    var username_Dict_age = [String: Int]()
    var username_Dict_height = [String: Int]()
    var username_Dict_gender = [String: String]()
    var username_Dict_levelExp = [String: Int]()
    var username_Dict_activityGoal = [String: String]()
    var username_Dict_activityLevel = [String: Int]()
    var username_Dict_goalWeight = [String: Int]()
    var username_Dict_userId = [String: Int]()
    var username_Dict_securityQuestion = [String: Int]()
    var username_Dict_securityAnswer = [String: String]()
    
    var isLoggedIn = false
    
    var checkbox = CheckBox()
    var usernameEntered = ""
    var usernameSaved = ""
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var isChecked = Bool()
    
    // This method gets called first when the view is shown
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adding in rounded corners to the buttons
        loginButton.layer.cornerRadius = 8
        signupButton.layer.cornerRadius = 8
        facebookButton.layer.cornerRadius = 8
        parseJSONForUserAccountAuthorization()
//        isChecked = NSUserDefaults.standardUserDefaults().boolForKey("isBtnChecked")
//        checkbox.isChecked = isChecked
        
    }
    
    // Action call for the checkBoxButton
    // When the check box button is touched, the states of the checkbox images will change
    @IBAction func checkBoxButtonTapped(sender: UIButton)
    {
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        parseJSONForUserAccountAuthorization()
        //print(username_Dict_firstName)
        //print(usernameAndPasswordDict)
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
                    firstName = jsonDataDictInfo["firstName"] as! String
                    lastName = jsonDataDictInfo["lastName"] as! String
                    email = jsonDataDictInfo["email"] as! String
                    age = jsonDataDictInfo["age"] as! Int
                    gender = jsonDataDictInfo["gender"] as! String
                    height = jsonDataDictInfo["height"] as! Int
                    levelExp = jsonDataDictInfo["points"] as! Int
                    activityLevel = jsonDataDictInfo["activityLevel"] as! Int
                    activityGoal = jsonDataDictInfo["activityGoal"] as! String
                    goalWeight = jsonDataDictInfo["goalWeight"] as! Int
                    userId = jsonDataDictInfo["id"] as! Int
                    securityQuestion = jsonDataDictInfo["securityQuestion"] as! Int
                    securityAnswer = jsonDataDictInfo["securityAnswer"] as! String
                    
                    // Password is value, username is key
                    usernameAndPasswordDict[username] = password
                    
                    // Weight is value, username is key
                    userWeightDict[username] = weight
                    
                    // dict[KEY] = VALUE
                    username_Dict_email[username] = email
                    username_Dict_firstName[username] = firstName
                    username_Dict_lastName[username] = lastName
                    username_Dict_age[username] = age
                    username_Dict_height[username] = height
                    username_Dict_gender[username] = gender
                    username_Dict_levelExp[username] = levelExp
                    username_Dict_goalWeight[username] = goalWeight
                    username_Dict_activityLevel[username] = activityLevel
                    username_Dict_activityGoal[username] = activityGoal
                    username_Dict_userId[username] = userId
                    username_Dict_securityAnswer[username] = securityAnswer
                    username_Dict_securityQuestion[username] = securityQuestion
                    
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
    
    // This method is called when the user taps Return on the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Deactivate the text field and remove the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // User authenication and authorization.
    @IBAction func loginButtonTapped(sender: UIButton)
    {
        usernameEntered = usernameTextField.text!
        let passwordEntered = passwordTextField.text
        
        if ((usernameEntered ?? "").isEmpty || (passwordEntered ?? "").isEmpty)
        {
            showAlertViewControllers("Sign in Failed!", errorMessage: "Please enter your username and password!")
        }
        
        usernameSaved = usernameEntered
        
        // User authentication: Checks to see if the dictionary has the key-value pair. If it does, then grab the value
        // as password and checks to see if the user enters the value to the key correctly.
        if let passwordValue = usernameAndPasswordDict[usernameEntered]
        {
            if (passwordValue == passwordEntered)
            {
                if let weightValue = userWeightDict[usernameEntered]
                {
                    // Assign value to variable to pass downstream
                    weight = weightValue
                }
                
                
                if let emailValue = username_Dict_email[usernameEntered]
                {
                    email = emailValue
                }
                
                if let firstNameValue = username_Dict_firstName[usernameEntered]
                {
                    firstName = firstNameValue
                }
                
                if let lastNameValue = username_Dict_lastName[usernameEntered]
                {
                    lastName = lastNameValue
                }
                
                if let ageValue = username_Dict_age[usernameEntered]
                {
                    age = ageValue
                }
                
                if let heightValue = username_Dict_height[usernameEntered]
                {
                    height = heightValue
                }
                
                if let levelExpValue = username_Dict_levelExp[usernameEntered]
                {
                    levelExp = levelExpValue
                }
                
                if let genderValue = username_Dict_gender[usernameEntered]
                {
                    gender = genderValue
                }
                
                if let activityLevelValue = username_Dict_activityLevel[usernameEntered]
                {
                    activityLevel = activityLevelValue
                }
                
                if let activityGoalValue = username_Dict_activityGoal[usernameEntered]
                {
                    activityGoal = activityGoalValue
                }
                
                if let goalWeightValue = username_Dict_goalWeight[usernameEntered]
                {
                    goalWeight = goalWeightValue
                }
                
                if let userIdValue = username_Dict_userId[usernameEntered]
                {
                    userId = userIdValue
                }
                
                if let securityQuestionValue = username_Dict_securityQuestion[usernameEntered]
                {
                    securityQuestion = securityQuestionValue
                }
                
                if let securityAnswerValue = username_Dict_securityAnswer[usernameEntered]
                {
                    securityAnswer = securityAnswerValue
                }
                
                
                // Create a entry onto the plist
                applicationDelegate.userAccountInfo.setObject(weight, forKey: "User Weight")
                applicationDelegate.userAccountInfo.setObject(usernameEntered, forKey: "Username")
                applicationDelegate.userAccountInfo.setObject(passwordEntered!, forKey: "Password")
                applicationDelegate.userAccountInfo.setObject(email, forKey: "Email")
                applicationDelegate.userAccountInfo.setObject(lastName, forKey: "Last Name")
                applicationDelegate.userAccountInfo.setObject(firstName, forKey: "First Name")
                applicationDelegate.userAccountInfo.setObject(age, forKey: "Age")
                applicationDelegate.userAccountInfo.setObject(gender, forKey: "Gender")
                applicationDelegate.userAccountInfo.setObject(levelExp, forKey: "Exp")
                applicationDelegate.userAccountInfo.setObject(height, forKey: "Height")
                applicationDelegate.userAccountInfo.setObject(activityGoal, forKey: "Activity Goal")
                applicationDelegate.userAccountInfo.setObject(activityLevel, forKey: "Current Activity Level")
                applicationDelegate.userAccountInfo.setObject(goalWeight, forKey: "Goal Weight")
                applicationDelegate.userAccountInfo.setObject(userId, forKey: "id")
                applicationDelegate.userAccountInfo.setObject(securityQuestion, forKey: "Security Question")
                applicationDelegate.userAccountInfo.setObject(securityAnswer, forKey: "Security Answer")
                
                
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
