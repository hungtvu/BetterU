//
//  SignInViewController.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // Initializing and making object references to the UITextField class
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    // Initializing and making object references to the UIButton class
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var checkBoxButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
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
    var userIdFromProgress = 0
    var logDate = 0
    var caloriesIn = 0
    var caloriesOut = 0
    var miles = 0
    var steps = 0
    
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
    var userId_Dict_logDate = [Int: Int]()
    var userId_Dict_miles = [Int: Int]()
    var userId_Dict_steps = [Int: Int]()
    var userId_Dict_caloriesIn = [Int: Int]()
    var userId_Dict_caloriesOut = [Int: Int]()
    
    var isLoggedIn = false
    
    var usernameEntered = ""
    var usernameSaved = ""
    
    var userIdArrayFromProgress = [Int]()
    var doesProgressHaveId = false
    
    let calendar = NSCalendar.currentCalendar()
    var epochArray = [Int]()
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var isChecked = Bool()
    
    // This method gets called first when the view is shown
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adding in rounded corners to the buttons
        loginButton.layer.cornerRadius = 8
        signupButton.layer.cornerRadius = 8
        parseJSONForUserAccountAuthorization()

        parseProgressJson()
        
        var date = calendar.startOfDayForDate(NSDate())
        
        // Grabs the last 6 days from the current time as now
        for _ in 1 ... 30 {
            
            let epochTimeStamp = Int(floor(date.timeIntervalSince1970))
            epochArray.append(epochTimeStamp)
            
            date = calendar.dateByAddingUnit(.NSDayCalendarUnit, value: -1, toDate: date, options: [])!
        }
        

    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        parseJSONForUserAccountAuthorization()
    }
    
    func parseProgressJson()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress"
        
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
                
                let jsonDataArray = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                
                var jsonDataDictInfo: NSDictionary = NSDictionary()
                var id = 0
                
                var i = 0
                while (i < jsonDataArray.count)
                {
                    jsonDataDictInfo = jsonDataArray[i] as! NSDictionary
                    id = jsonDataDictInfo["userId"] as! Int
                    userIdArrayFromProgress.append(jsonDataDictInfo["userId"] as! Int)
                    
                    caloriesIn = jsonDataDictInfo["caloriesIn"] as! Int
                    caloriesOut = jsonDataDictInfo["caloriesOut"] as! Int
                    miles = jsonDataDictInfo["miles"] as! Int
                    steps = jsonDataDictInfo["steps"] as! Int
                    
                    userId_Dict_logDate[id] = jsonDataDictInfo["logDate"] as? Int
                    userId_Dict_steps[id] = steps
                    userId_Dict_caloriesIn[id] = caloriesIn
                    userId_Dict_caloriesOut[id] = caloriesOut
                    userId_Dict_miles[id] = miles
                    
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
                
                if let logDateValue = userId_Dict_logDate[userId]
                {
                    logDate = logDateValue
                }
                
                if let milesValue = userId_Dict_miles[userId]
                {
                    miles = milesValue
                }
                
                if let caloriesInValue = userId_Dict_caloriesIn[userId]
                {
                    caloriesIn = caloriesInValue
                }
                
                if let caloriesOutValue = userId_Dict_caloriesOut[userId]
                {
                    caloriesOut = caloriesOutValue
                }
                
                if let stepsValue = userId_Dict_steps[userId]
                {
                    steps = stepsValue
                }
                
                doesProgressHaveId = false
                
                var i = 0
                while (i < userIdArrayFromProgress.count)
                {
                    if userIdArrayFromProgress[i] == userId
                    {
                        doesProgressHaveId = true
                        break
                    }
                    i = i + 1
                }
                
                // Only execute and create new progress entries if the user id wasn't in the progress database
                if !doesProgressHaveId
                {
                    var i = 0
                    while (i < epochArray.count) {
                        //endpoint to database you want to post to
                        let postToProgressEndPoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress"
                        
                        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
                        //Format is = "Field": value
                        let newPostForProgress = ["caloriesIn": 0, "caloriesOut": 0, "logDate": epochArray[i], "miles": 0, "steps": 0, "userId": userId, "weight": Double(weight)]
                        
                        //Creating the request to post the newPost JSON var.
                        Alamofire.request(.POST, postToProgressEndPoint, parameters: newPostForProgress as? [String : AnyObject], encoding: .JSON)
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
                        i = i + 1
                    }
                }
                
//                // Adds a new entry to the progress table everyday for that specific user
//                if (doesProgressHaveId && logDate != epochArray[0])
//                {
//                    //endpoint to database you want to post to
//                    let postToProgressEndPoints: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress"
//                    
//                    //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
//                    //Format is = "Field": value
//                    let existedPostForProgress = ["caloriesIn": caloriesIn, "caloriesOut": caloriesOut, "logDate": epochArray[0], "miles": miles, "steps": steps, "userId": userId, "weight": Double(weight)]
//
//                    //Creating the request to post the newPost JSON var.
//                    Alamofire.request(.POST, postToProgressEndPoints, parameters: existedPostForProgress as? [String : AnyObject], encoding: .JSON)
//                        .responseJSON { response in
//                            guard response.result.error == nil else {
//                                // got an error in getting the data, need to handle it
//                                print("error calling GET on /posts/1")
//                                print(response.result.error!)
//                                return
//                            }
//                            
//                            if let value: AnyObject = response.result.value {
//                                // handle the results as JSON, without a bunch of nested if loops
//                                // this might not return anything here, but check the DB just in case. It might post anyway
//                                let post = JSON(value)
//                                print("The post is: " + post.description)
//                            }
//                    }
//                }
                
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
