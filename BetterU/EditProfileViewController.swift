//
//  EditProfileViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/4/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

/* CURRENT BUG (Small): Picker option for height in feet and inches aren't resetting properly. If a user decides to change
                        their height to something else and changed their mind, the system will still update their height
                        to the new change. Ex: User's original height is 6' 0'', then they want to change it to 6' 2''
                        but then decide to cancel it. The system will still read 6' 2'' even though the heightTextField
                        has their correct original height as placeholder. */

/* CURRENT BUG (Small): When canceling the pickerView, ageTextField and heightTextField are both resetting */

class EditProfileViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate {

    // Initialize object references for specific items on the view
    @IBOutlet var editPhotoButton: UIButton!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var weightTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    
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
    
    // Initialize picker views and picker options for age and height
    var pickerViewForAge = UIPickerView()
    var pickerViewForHeight = UIPickerView()
    
    var pickerOptionForAge = [String]()
    var pickerOptionForHeightFt = [String]()
    var pickerOptionForHeightInches = [String]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerViewForHeight.delegate = self
        self.pickerViewForAge.delegate = self
        
        pickerViewForAge.tag = 1
        pickerViewForHeight.tag = 2
        
        // Sets the picker options for age
        var i = 13
        while (i < 99)
        {
            pickerOptionForAge.append(String(i))
            i = i + 1
        }
        
        // Sets the picker option for the height in feet
        var ft = 2
        while (ft < 9)
        {
            pickerOptionForHeightFt.append(String(ft) + "'")
            ft = ft + 1
        }
        
        // Sets the picker option for the height in inches
        var inches = 0
        while (inches < 12)
        {
            pickerOptionForHeightInches.append(String(inches) + "''")
            inches = inches + 1
        }
        
        saveButton.layer.cornerRadius = 8
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeightWeightViewController.hideKeyboard(_:)))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)
        
        registerForKeyboardNotifications()
        
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
        
        // Moves the segmented control to the appropriate position based on gender
        if gender == "M"
        {
            genderSegmentedControl.selectedSegmentIndex = 0
        }
        else
        {
            genderSegmentedControl.selectedSegmentIndex = 1
        }
        
        emailLabel!.text = email
        firstNameTextField!.text = "\(firstName)"
        lastNameTextField!.text = "\(lastName)"
        ageTextField!.text = "\(age)"
        
        firstNameTextField!.placeholder = "\(firstName)"
        lastNameTextField!.placeholder = "\(lastName)"
        ageTextField!.placeholder = "\(age)"
        
        // Calculate the height in feet and inches
        heightFtCalculated = height/12
        heightInCalculated = height % 12
        
        heightTextField!.text = "\(heightFtCalculated)' \(heightInCalculated)''"
        weightTextField!.text = "\(weight)"
        
        heightTextField!.placeholder = "\(heightFtCalculated)' \(heightInCalculated)''"
        weightTextField!.placeholder = "\(weight) lbs"
        
        // Adds a toolbar on top of the picker view so that the user can cancel their selection
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 65/255, green: 192/255, blue: 247/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adds the button within the toolbar with an action
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AgeGenderViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AgeGenderViewController.cancelPicker(_:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        // Sets the textfield inputs to become the pickerview
        heightTextField!.inputView = pickerViewForHeight
        ageTextField!.inputView = pickerViewForAge
        
        // Sets the toolbar within the textfield
        heightTextField!.inputAccessoryView = toolBar
        ageTextField!.inputAccessoryView = toolBar
   
    }
    
    /*
     ----------------------------------------------------------
     MARK: - Allows the textfield to have a max of 5 characters
     ----------------------------------------------------------
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 3 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 3
        }
        return true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     ---------------------------------------------
     MARK: - Register and Unregister Notifications
     ---------------------------------------------
     */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
        
        parseJson()
        
        // Moves the segmented control to the appropriate position based on gender
        if gender == "M"
        {
            genderSegmentedControl.selectedSegmentIndex = 0
        }
        else
        {
            genderSegmentedControl.selectedSegmentIndex = 1
        }
        
        emailLabel!.text = email
        firstNameTextField!.text = "\(firstName)"
        lastNameTextField!.text = "\(lastName)"
        ageTextField!.text = "\(age)"
        
        firstNameTextField!.placeholder = "\(firstName)"
        lastNameTextField!.placeholder = "\(lastName)"
        ageTextField!.placeholder = "\(age)"
        
        // Calculate the height in feet and inches
        heightFtCalculated = height/12
        heightInCalculated = height % 12
        
        heightTextField!.text = "\(heightFtCalculated)' \(heightInCalculated)''"
        weightTextField!.text = "\(weight)"
        
        heightTextField!.placeholder = "\(heightFtCalculated)' \(heightInCalculated)''"
        weightTextField!.placeholder = "\(weight) lbs"
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    @IBAction func editPhotoButtonTapped(sender: UIButton) {
    }
   
    @IBAction func saveButtonTapped(sender: UIButton)
    {
        var ageToUse = ""
        var lastNameToUse = ""
        var firstNameToUse = ""
        var weightToUse = ""
        
        var heightToUse = ""
        
        // If the user has changed their age
        if ageTextField.text != String(age)
        {
            ageToUse = ageTextField!.text!
        }
        
        else
        {
            ageToUse = String(age)
        }
        
        // If the user has changed their last name
        if lastNameTextField.text != lastName
        {
            lastNameToUse = lastNameTextField!.text!
        }
        
        else
        {
            lastNameToUse = lastName
        }
        
        // If the user has changed their first name
        if firstNameTextField.text != firstName
        {
            firstNameToUse = firstNameTextField!.text!
        }
        
        else
        {
            firstNameToUse = firstName
        }
        
        // If the user has changed their weight
        if weightTextField.text != String(weight)
        {
            weightToUse = weightTextField!.text!
        }
            
        else
        {
            weightToUse = String(weight)
        }
        
        // If the user has changed their height
        if heightTextField.text != "\(heightFtCalculated)' \(heightInCalculated)''"
        {
            heightFt = heightFt.stringByReplacingOccurrencesOfString("'", withString: "")
            heightInches = heightInches.stringByReplacingOccurrencesOfString("''", withString: "")
            
            heightToUse = String(Int(heightFt)! * 12 + Int(heightInches)!)
        }
        else
        {
            heightToUse = String(height)
        }
        
        // If the user is a male that changed into a female
        if gender == "M" && genderSegmentedControl.selectedSegmentIndex != 0
        {
            gender = "F"
            genderSegmentedControl.selectedSegmentIndex = 1
        }
        
        // If the user is a female who changed into a male
        else if gender == "F" && genderSegmentedControl.selectedSegmentIndex != 1
        {
            gender = "M"
            genderSegmentedControl.selectedSegmentIndex = 0
        }
        
        
        //don't forget to import Alamofire and SwiftyJSON
        
        //endpoint to database you want to post to
        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/\(id)"
        
        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
        //Format is = "Field": value
        let newPost = ["DCSkipped": 0, "WCSkipped": 0, "activityGoal": activityGoal, "activityLevel": currentActivityLevel, "age": ageToUse, "bmr": "testBMR", "dailyChallengeIndex": 0, "email": email, "firstName": firstNameToUse, "gender": gender, "goalType": 0, "goalWeight": goalWeight, "height": heightToUse, "id": id, "lastName": lastNameToUse, "password": password, "points": 0, "securityAnswer": securityAnswer, "securityQuestion": securityQuestion, "targetCalories": 0, "units": "I", "username": username, "weeklyChallengeIndex": 0, "weight": weightToUse]
        
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
     --------------------------------------------------
     MARK: - Toolbar actions with the press of a button
     --------------------------------------------------
     */
    func donePicker(sender: UIPickerView)
    {
        ageTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
    }
    
    func cancelPicker(sender: UIPickerView)
    {
        ageTextField!.text = ""
        ageTextField.resignFirstResponder()
        heightTextField!.text = ""
        
        // Resets the picker options
        heightFt = String(height/12)
        heightInches = String(height%12)
        
        var i = 0
        while i < pickerOptionForHeightFt.indexOf(heightFt + "'")
        {
            pickerOptionForHeightFt.startIndex.advancedBy(i)
            i = i + 1
        }
        
        var j = 0
        while j < pickerOptionForHeightInches.indexOf(heightInches + "''")
        {
            pickerOptionForHeightInches.startIndex.advancedBy(j)
            j = j + 1
        }
    
        heightTextField.resignFirstResponder()
    }

    
    /*
     -----------------------------------
     MARK: - PickerView Delegate methods
     -----------------------------------
     */
    
    // Setting the number of components (columns) in the pickerview
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1
        {
            return 1
        }
        
        return 2
    }
    
    // Set the number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1
        {
            return pickerOptionForAge.count
        }
        
        else {
            if component == 0
            {
                return pickerOptionForHeightFt.count
            }
            
            return pickerOptionForHeightInches.count
        }
    }
    
    // Set title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1
        {
            return pickerOptionForAge[row]
        }
        
        else
        {
            if component == 0
            {
                return pickerOptionForHeightFt[row]
            }
            
            return pickerOptionForHeightInches[row]
        }
    }
    
    // Updates the textfield when the picker view is selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     
        
        if pickerView.tag == 1
        {
            ageTextField!.text = pickerOptionForAge[row]
        }
        
        else
        {
            if component == 0
            {
                heightFt = pickerOptionForHeightFt[row]
            }
            
            if component == 1
            {
                heightInches = pickerOptionForHeightInches[row]
            }
           
            heightTextField!.text = "\(heightFt) \(heightInches)"
        }
    }

    
    
    // Stops the scrollview from scrolling horizontally
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView.contentOffset.x != 0
        {
            var offset: CGPoint = scrollView.contentOffset
            offset.x = 0
            scrollView.contentOffset = offset
        }
    }
    
    // Allows the keyboard to hide by the user's interaction (background touch)
    func hideKeyboard(sender: UIScrollView)
    {
        scrollView.endEditing(true)
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
            selector:   #selector(HeightWeightViewController.keyboardWillShow(_:)),    // <-- Call this method upon Keyboard Will SHOW Notification
            name:       UIKeyboardWillShowNotification,
            object:     nil)
        
        notificationCenter.addObserver(self,
            selector:   #selector(HeightWeightViewController.keyboardWillHide(_:)),    //  <-- Call this method upon Keyboard Will HIDE Notification
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
        let weightTextFieldRect: CGRect? = weightTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let weightActiveTextFieldOrigin: CGPoint? = weightTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, weightActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(weightTextFieldRect!, animated:true)
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
    
    // This method is called when the user taps Return on the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Deactivate the text field and remove the keyboard
        textField.resignFirstResponder()
        
        return true
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
