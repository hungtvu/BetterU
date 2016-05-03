//
//  LogExerciseViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/17/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LogExerciseViewController: UIViewController, UITextFieldDelegate {

    // Initialize object references for the various objects under the View Controller
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var repsPerSetTextField: UITextField!
    @IBOutlet var setsTextField: UITextField!
    @IBOutlet var weightPerSetTextField: UITextField!
    @IBOutlet var lengthOfWorkoutTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var intensityLevelLabel: UILabel!
    @IBOutlet var intensitySlider: UISlider!
    
    @IBOutlet var descriptionRightLabel: UILabel!
    @IBOutlet var repsPerSetRightLabel: UILabel!
    @IBOutlet var setsRightLabel: UILabel!
    @IBOutlet var weightLbsRightLabel: UILabel!
    @IBOutlet var minsRightLabel: UILabel!
    @IBOutlet var caloriesBurnedLabel: UILabel!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var userId = 0
    
    // Initialize variables for the PUT request
    var caloriesIn = 0
    var caloriesOut = 0
    var miles = 0.0
    var steps = 0
    var weight = 0.0
    var logDate = 0
    var epochTime = 0
    
    var hasTouchedRows = false
    
    var bodyWeightLbs = 0
    var bodyWeightKg = 0.0
    
    // Only calls and stores in the variable when the user has touched a row within the Exercise View Controller
    var workoutDescriptionPassed = ""
    var repsPerSetsPassed = ""
    var numberSetsPassed = ""
    var weightLbsPassed = ""
    var workoutLengthPassed = ""
    var workoutIntensityPassed = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId = applicationDelegate.userAccountInfo["id"] as! Int
        
        intensityLevelLabel.text! = String(1)
        registerForKeyboardNotifications()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LogExerciseViewController.hideKeyboard(_:)))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)
        
        // Set up the Add button on the right of the navigation bar to call the addRecipe method when tapped
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(LogExerciseViewController.addExercise(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        // This is the body weight in pounds, so we must convert it to kg
        bodyWeightLbs = applicationDelegate.userAccountInfo["User Weight"] as! Int
        
        // Gets body weight in kg from pounds
        bodyWeightKg = Double(bodyWeightLbs)/2.2046
        
        if hasTouchedRows
        {
            descriptionTextField.text! = workoutDescriptionPassed
            repsPerSetTextField.text! = repsPerSetsPassed
            setsTextField.text! = numberSetsPassed
            weightPerSetTextField.text! = weightLbsPassed
            lengthOfWorkoutTextField.text! = workoutLengthPassed
            intensityLevelLabel.text! = workoutIntensityPassed
            intensitySlider.value = Float(workoutIntensityPassed)!
            intensitySliderChanged(intensitySlider)
        }
        
        descriptionRightLabel.alpha = 0
        repsPerSetRightLabel.alpha = 0
        setsRightLabel.alpha = 0
        weightLbsRightLabel.alpha = 0
        minsRightLabel.alpha = 0
        
        let date: NSDate = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate = cal.startOfDayForDate(date)
        epochTime = Int(newDate.timeIntervalSince1970)
        parseProgressForSpecificDate(epochTime)

    }
    
    func parseProgressForSpecificDate(dateInEpoch: Int)
    {
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/\(dateInEpoch)"
        
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
                
                /*                  */
                let jsonData = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                caloriesIn = jsonData["caloriesIn"] as! Int
                caloriesOut = jsonData["caloriesOut"] as! Int
                logDate = jsonData["logDate"] as! Int
                miles = jsonData["miles"] as! Double
                steps = jsonData["steps"] as! Int
                weight = jsonData["weight"] as! Double
                
                
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

    
    /*
     ----------------------------------
     MARK: - Add Exercise Button Tapped
     ----------------------------------
     */
    
    func addExercise(sender: AnyObject)
    {
        // Initialize local variables
        let descriptionEntered = descriptionTextField.text!
        let repsPerSetEntered = repsPerSetTextField.text!
        let setsEntered = setsTextField.text!
        let weightPerSetEntered = weightPerSetTextField.text!
        let lengthOfWorkoutEntered = lengthOfWorkoutTextField.text!
        let intensitylevel = intensityLevelLabel.text!
        
        var exerciseInfoArray = [String]()
        
        if descriptionEntered == "" || lengthOfWorkoutEntered == ""
        {
            self.showErrorMessage("Please complete all required entries.", errorTitle: "One or More Entries Not Filled!")
            return
        }
        
        
        // Update the new list of exercise
        // If we are updating the set of workout that has already been created
        if hasTouchedRows
        {
            descriptionTextField.userInteractionEnabled = false
            
            workoutDescriptionPassed = descriptionEntered
            repsPerSetsPassed = repsPerSetEntered
            numberSetsPassed = setsEntered
            weightLbsPassed = weightPerSetEntered
            workoutLengthPassed = lengthOfWorkoutEntered
            workoutIntensityPassed = intensitylevel
            
            exerciseInfoArray.append(workoutDescriptionPassed)
            exerciseInfoArray.append(repsPerSetsPassed)
            exerciseInfoArray.append(numberSetsPassed)
            exerciseInfoArray.append(weightLbsPassed)
            exerciseInfoArray.append(workoutLengthPassed)
            exerciseInfoArray.append(workoutIntensityPassed)
            
            var caloriesBurned = calculateCaloriesBurned(Int(workoutIntensityPassed)!, bodyWeightKg: bodyWeightKg, workoutIntervalMins: Int(workoutLengthPassed)!)
            
            // Rounds to the nearest hundredth
            caloriesBurned = round(100 * caloriesBurned)/100
            
            exerciseInfoArray.append(String(caloriesBurned))
            
            applicationDelegate.savedLoggedExercisesDict.setValue(exerciseInfoArray, forKey: workoutDescriptionPassed)
        }
            
        // Creates a new value inside the plist
        else
        {
            exerciseInfoArray.append(descriptionEntered)
            exerciseInfoArray.append(repsPerSetEntered)
            exerciseInfoArray.append(setsEntered)
            exerciseInfoArray.append(weightPerSetEntered)
            exerciseInfoArray.append(lengthOfWorkoutEntered)
            exerciseInfoArray.append(intensitylevel)
            
            var caloriesBurned = calculateCaloriesBurned(Int(intensitylevel)!, bodyWeightKg: bodyWeightKg, workoutIntervalMins: Int(lengthOfWorkoutEntered)!)
            
            // Rounds to the nearest hundredth
            caloriesBurned = round(100 * caloriesBurned)/100
            
            exerciseInfoArray.append(String(caloriesBurned))

            applicationDelegate.savedLoggedExercisesDict.setValue(exerciseInfoArray, forKey: descriptionEntered)
        }
        
        var caloriesBurnedFromText = caloriesBurnedLabel.text!
        caloriesBurnedFromText = String(Int(caloriesBurnedLabel.text!)! + caloriesOut)
        
        //endpoint to database you want to post to
        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/\(epochTime)"
        
        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
        //Format is = "Field": value
        let newPost = ["caloriesIn": caloriesIn, "caloriesOut":Int(caloriesBurnedFromText)!,"logDate":logDate,"miles":miles,"steps":steps,"userId":userId,"weight":weight]
        
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
        
        self.navigationController?.popViewControllerAnimated(true)
        //let journalView = JournalViewController()
        //self.navigationController?.popToViewController(journalView.childViewControllers[0], animated: true)
    }
    
    /* As soon as the user begins editing the textfield, the right label shows up. This right label helps the user keep track of what data they are inputting */
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if textField.tag == 1
        {
            descriptionRightLabel.alpha = 1
        }
        else if textField.tag == 2
        {
            repsPerSetRightLabel.alpha = 1
        }
        else if textField.tag == 3
        {
            setsRightLabel.alpha = 1
        }
        else if textField.tag == 4
        {
            weightLbsRightLabel.alpha = 1
        }
        else if textField.tag == 5
        {
            minsRightLabel.alpha = 1
        }
    }
    
    /* Once the user has stopped editing, the right label will disappear IF the user does not have any information inside the textfield. */
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField.tag == 1
        {
            if textField.text! == ""
            {
                descriptionRightLabel.alpha = 0
            }
        }
        else if textField.tag == 2
        {
            if textField.text! == ""
            {
                repsPerSetRightLabel.alpha = 0
            }
        }
        else if textField.tag == 3
        {
            if textField.text! == ""
            {
                setsRightLabel.alpha = 0
            }
        }
        else if textField.tag == 4
        {
            if textField.text! == ""
            {
                weightLbsRightLabel.alpha = 0
            }
        }
        else if textField.tag == 5
        {
            if textField.text! == ""
            {
                minsRightLabel.alpha = 0
            }
        }
    }
    
    /* This function uses the formula: MET Value  x  3.5  x kg body weight  ÷  200 x minutes in order to calculate how much calories have been burned in this workout session */
    func calculateCaloriesBurned(intensityLevel: Int, bodyWeightKg: Double, workoutIntervalMins: Int) -> Double
    {
        return ((Double(intensityLevel) * 3.5 * bodyWeightKg)/200) * Double(workoutIntervalMins)
    }

    // Allows the keyboard to hide by the user's interaction (background touch)
    func hideKeyboard(sender: UIScrollView)
    {
        scrollView.endEditing(true)
    }
    
    @IBAction func intensitySliderChanged(sender: UISlider)
    {
        let sliderIntValue = Int(sender.value)    // Conversion from Float to Integer
        
        /* The thumb color and the line color will change depending on which value is being updated */
        switch sliderIntValue
        {
        case 1:
            sender.thumbTintColor = UIColor(red: 65/255, green: 192/255, blue: 247/255, alpha: 1)
            sender.tintColor = UIColor(red: 65/255, green: 192/255, blue: 247/255, alpha: 1)
            break
            
        case 2:
            sender.thumbTintColor = UIColor(red: 102/255, green: 205/255, blue: 170/255, alpha: 1)
            sender.tintColor = UIColor(red: 102/255, green: 205/255, blue: 170/255, alpha: 1)
            break
            
        case 3:
            sender.thumbTintColor = UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 1)
            sender.tintColor = UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 1)
            break
            
        case 4:
            sender.thumbTintColor = UIColor(red: 127/255, green: 255/255, blue: 0/255, alpha: 1)
            sender.tintColor = UIColor(red: 127/255, green: 255/255, blue: 0/255, alpha: 1)
            break
            
        case 5:
            sender.thumbTintColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1)
            sender.tintColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1)
            break
            
        case 6:
            sender.thumbTintColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
            sender.tintColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
            break
            
        case 7:
            sender.thumbTintColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
            sender.tintColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
            break
            
        case 8:
            sender.thumbTintColor = UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1)
            sender.tintColor = UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1)
            break
            
        case 9:
            sender.thumbTintColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1)
            sender.tintColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1)
            break
            
        case 10:
            sender.thumbTintColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            sender.tintColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            break
            
        default:
            break
            
        }
        
        /*
         Slider's integer value is converted into a String value.
         The String value is assigned to be the slider's label text.
         */
        
        intensityLevelLabel.text = String(sliderIntValue)  // Conversion from Integer to String
        
        // Initialize local variables
        var lengthOfWorkoutEntered = lengthOfWorkoutTextField.text!
        
        if lengthOfWorkoutEntered == ""
        {
            lengthOfWorkoutEntered = String(0)
        }
        
        caloriesBurnedLabel.text = String(Int(calculateCaloriesBurned(sliderIntValue, bodyWeightKg: bodyWeightKg, workoutIntervalMins: Int(lengthOfWorkoutEntered)!)))
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
            selector:   #selector(LogExerciseViewController.keyboardWillShow(_:)),    // <-- Call this method upon Keyboard Will SHOW Notification
            name:       UIKeyboardWillShowNotification,
            object:     nil)
        
        notificationCenter.addObserver(self,
            selector:   #selector(LogExerciseViewController.keyboardWillHide(_:)),    //  <-- Call this method upon Keyboard Will HIDE Notification
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
        let descriptionTextFieldRect: CGRect? = descriptionTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let descriptionActiveTextFieldOrigin: CGPoint? = descriptionTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, descriptionActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(descriptionTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let repsPerSetTextFieldRect: CGRect? = repsPerSetTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let repsPerSetActiveTextFieldOrigin: CGPoint? = repsPerSetTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, repsPerSetActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(repsPerSetTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let setsTextFieldRect: CGRect? = setsTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let setsActiveTextFieldOrigin: CGPoint? = setsTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, setsActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(setsTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let weightPerSetTextFieldRect: CGRect? = weightPerSetTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let weightPerSetActiveTextFieldOrigin: CGPoint? = weightPerSetTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, weightPerSetActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(weightPerSetTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let lengthOfWorkoutTextFieldRect: CGRect? = lengthOfWorkoutTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let lengthOfWorkoutActiveTextFieldOrigin: CGPoint? = lengthOfWorkoutTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, lengthOfWorkoutActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(lengthOfWorkoutTextFieldRect!, animated:true)
        }
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
