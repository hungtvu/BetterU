//
//  AccountDetailsViewController.swift
//  BetterU
//
//  Created by Michael Bulgakov on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AccountDetailsViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate {
    
    //age, gender, heightft, heightin, curweight, goalweight
    var accountInfoPassed = [String]()
    var accountInfoPass = [String]()
    
    // Current activity and goal activity info passed
    var currentActivity = 0
    var goalActivity = String()
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var createPasswordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var securityQuestionTextField: UITextField!
    @IBOutlet var securityAnswerTextField: UITextField!
    
    // Initializing 2 picker view options and a pickerview
    var pickerSecurityQuestions = [String]()
    let pickerView = UIPickerView()
    var pickerIndex = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerSecurityQuestions.append("In what city were you born?")
        pickerSecurityQuestions.append("What elementary school did you attend?")
        pickerSecurityQuestions.append("What is the last name of your most favorite teacher?")
        pickerSecurityQuestions.append("What is your father's middle name?")
        pickerSecurityQuestions.append("What is your most favorite pet's name?")
               
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeightWeightViewController.hideKeyboard(_:)))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)

        
        registerForKeyboardNotifications()
        
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
        
        // Adds the pickerview to the textfield
        securityQuestionTextField.inputView = pickerView
        
        // Adds the toolbar to the textfield on top of the pickerview
        securityQuestionTextField.inputAccessoryView = toolBar
        
        //print(accountInfoPassed)

    }
    
    // Allows the keyboard to hide by the user's interaction (background touch)
    func hideKeyboard(sender: UIScrollView)
    {
        scrollView.endEditing(true)
    }
    
    /*
     --------------------------------------------------
     MARK: - Toolbar actions with the press of a button
     --------------------------------------------------
     */
    func donePicker(sender: UIPickerView)
    {
        securityQuestionTextField.resignFirstResponder()
    }
    
    func cancelPicker(sender: UIPickerView)
    {
        securityQuestionTextField!.text = ""
        securityQuestionTextField.resignFirstResponder()
    }
    
    /*
     -----------------------------------
     MARK: - PickerView Delegate methods
     -----------------------------------
     */
    
    // Setting the number of components in the pickerview
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Set the number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerSecurityQuestions.count
    }
    
    // Set title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerSecurityQuestions[row]
    }
    
    // Updates the textfield when the picker view is selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        securityQuestionTextField.text = pickerSecurityQuestions[row]
        pickerIndex = row
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        
        if userNameTextField.text!.isEmpty{
            self.showErrorMessage("Please complete all required entries.", errorTitle: "Username Missing!")
            return
        }
        else if emailTextField.text!.isEmpty{
            self.showErrorMessage("Please complete all required entries.", errorTitle: "Email Missing!")
            
            return
        }
        else if createPasswordTextField.text!.isEmpty {

            self.showErrorMessage("Please create a new password.", errorTitle: "Password Missing!")
            return
        }
            
        else if createPasswordTextField.text!.characters.count < 8
        {
            self.showErrorMessage("Password must have a minimum of 8 characters.", errorTitle: "Invalid Password Length!")
            return
        }
            
        else if confirmPasswordTextField.text!.isEmpty{
            self.showErrorMessage("Please confirm your new password.", errorTitle: "Password Confirmation Missing!")
            return
        }
        else if createPasswordTextField.text! != confirmPasswordTextField.text!{
            self.showErrorMessage("Your new password does not match. Please try again.", errorTitle: "Password Mismatch!")
            return
        }
        
        else if securityQuestionTextField.text!.isEmpty || securityAnswerTextField.text!.isEmpty {
            self.showErrorMessage("Please choose your security question or enter your security answer.", errorTitle: "Security Details Missing!")
            return
        }
            
        else {
            
            let heightft = Int(accountInfoPassed[4])
            let heightin = Int(accountInfoPassed[5])
            
            let height = heightft!*12 + heightin!
            
            //don't forget to import Alamofire and SwiftyJSON
            
            //endpoint to database you want to post to
            let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user"
            
            //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
            //Format is = "Field": value
            let newPost = ["DCSkipped": 0, "WCSkipped": 0, "activityGoal": goalActivity, "activityLevel": currentActivity, "age": accountInfoPassed[2], "bmr": "testBMR", "dailyChallengeIndex": 0, "email": emailTextField.text!, "firstName": accountInfoPassed[0], "gender": accountInfoPassed[3], "goalType": 0, "goalWeight": accountInfoPassed[7], "height": height, "lastName": accountInfoPassed[1], "password": confirmPasswordTextField.text!, "points": 0, "securityAnswer": securityAnswerTextField!.text!, "securityQuestion": pickerIndex, "targetCalories": 0, "units": "I", "username": userNameTextField.text!, "weeklyChallengeIndex": 0, "weight": accountInfoPassed[6]]
            
            //Creating the request to post the newPost JSON var.
            Alamofire.request(.POST, postsEndpoint, parameters: newPost as? [String : AnyObject], encoding: .JSON)
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
            
            // Grabs the storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Grabs the view controller from the storyboard ID
            let signInViewcontroller = storyboard.instantiateViewControllerWithIdentifier("SignInView") as! SignInViewController
            
            // Presents the previous view controller
            self.presentViewController(signInViewcontroller, animated: true, completion: nil)        }
        
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
        let usernameTextFieldRect: CGRect? = userNameTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let userActiveTextFieldOrigin: CGPoint? = usernameTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, userActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(usernameTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let emailTextFieldRect: CGRect? = emailTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let emailActiveTextFieldOrigin: CGPoint? = emailTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, emailActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(emailTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let securityAnswerTextFieldRect: CGRect? = securityAnswerTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let securityAnswerActiveTextFieldOrigin: CGPoint? = securityAnswerTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, securityAnswerActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(securityAnswerTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let newPassTextFieldRect: CGRect? = createPasswordTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let newPassActiveTextFieldOrigin: CGPoint? = newPassTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, newPassActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(newPassTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let confirmPassTextFieldRect: CGRect? = confirmPasswordTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let confirmPassActiveTextFieldOrigin: CGPoint? = emailTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, confirmPassActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(confirmPassTextFieldRect!, animated:true)
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
        
        if textField.tag == 1 || textField.tag == 2 {
            if textField.text!.characters.count < 8 {
                self.showErrorMessage("Password must have a minimum of 8 characters.", errorTitle: "Invalid Password Length!")
            }
            self.view.endEditing(true)
        }
        
        // Deactivate the text field and remove the keyboard
        textField.resignFirstResponder()
        
        return true
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

    
//    "DCSkipped": "1",
//    "WCSkipped": "1",
//    "activityGoal": "Very Active",
//    "activityLevel": 0,
//    "age": 20,
//    "bmr": 1724,
//    "dailyChallengeIndex": 4,
//    "email": "jdoe@vt.edu",
//    "firstName": "John",
//    "gender": "M",
//    "goalType": 4,
//    "goalWeight": 130,
//    "height": 65,
//    "id": 1,
//    "lastName": "Doe",
//    "password": "password",
//    "points": 0,
//    "securityAnswer": "Virginia",
//    "securityQuestion": 3,
//    "targetCalories": 1800,
//    "units": "I",
//    "username": "jdoe",
//    "weeklyChallengeIndex": 2,
//    "weight": 155
//    

}
