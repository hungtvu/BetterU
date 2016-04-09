//
//  HeightWeightViewController.swift
//  BetterU
//
//  Created by Michael Bulgakov on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class HeightWeightViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    
    var accountInfoPassed = [String]()
    var accountInfoToPass = [String]()
    
    // Initialize required textfields
    @IBOutlet var heightFtTextField: UITextField!
    @IBOutlet var heightInTextField: UITextField!
    @IBOutlet var curWeightTextField: UITextField!
    @IBOutlet var goalWeightTextField: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    // Initializing 2 picker view options and a pickerview
    var pickOptionForHeightFt = [String]()
    var pickerOptionForHeightInches = [String]()
    let pickerViewForHeight = UIPickerView()
    
    // Reduce the limit of the textfield to 5 for weight
    let limitLength = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeightWeightViewController.hideKeyboard(_:)))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)
        
        // Initializes the first row for the picker view
        pickerOptionForHeightInches.append("")
        pickOptionForHeightFt.append("")
        
        // Sets the title for the height in feet
        var i = 2
        while (i < 9)
        {
            pickOptionForHeightFt.append(String(i) + "'")
            i = i + 1
        }
        
        // Sets the title for the height in inches
        var j = 0
        while (j < 12)
        {
            pickerOptionForHeightInches.append(String(j) + "''")
            j = j + 1
        }
        
        pickerViewForHeight.showsSelectionIndicator = true
        pickerViewForHeight.delegate = self
        pickerViewForHeight.dataSource = self
        
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
        heightFtTextField.inputView = pickerViewForHeight
        heightInTextField.inputView = pickerViewForHeight
        
        // Adds the toolbar to the textfield on top of the pickerview
        heightFtTextField.inputAccessoryView = toolBar
        heightInTextField.inputAccessoryView = toolBar
        
        registerForKeyboardNotifications()

    }
    
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
        heightFtTextField.resignFirstResponder()
        heightInTextField.resignFirstResponder()
    }
    
    func cancelPicker(sender: UIPickerView)
    {
        heightFtTextField!.text = ""
        heightInTextField!.text = ""
        heightInTextField.resignFirstResponder()
        heightFtTextField.resignFirstResponder()
    }
    
    /*
     ----------------------------------------------------------
     MARK: - Allows the textfield to have a max of 5 characters
     ----------------------------------------------------------
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
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
        let curWeightTextFieldRect: CGRect? = curWeightTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let curWeightActiveTextFieldOrigin: CGPoint? = curWeightTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, curWeightActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(curWeightTextFieldRect!, animated:true)
        }
        
        // Obtain the size of the active UITextField object
        let goalWeightTextFieldRect: CGRect? = goalWeightTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let goalWeightActiveTextFieldOrigin: CGPoint? = goalWeightTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, goalWeightActiveTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(goalWeightTextFieldRect!, animated:true)
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        if heightFtTextField.text!.isEmpty
        {
            self.showErrorMessage("BetterU needs to know your height to get you the best results!", errorTitle: "Whoops!")
            return
        }
        else if heightInTextField.text!.isEmpty
        {
            self.showErrorMessage("BetterU needs to know your height to get you the best results!", errorTitle: "Whoops!")
            return
        }
        else if curWeightTextField.text!.isEmpty
        {
            self.showErrorMessage("BetterU needs to know your current weight to get you the best results!", errorTitle: "Whoops!")
            
            return
        }
        else if goalWeightTextField.text!.isEmpty
        {
            self.showErrorMessage("BetterU needs to know your goal weight to get you the best results!", errorTitle: "Whoops!")
            
            return
        }
        else {
            accountInfoToPass = accountInfoPassed
            accountInfoToPass.append(heightFtTextField.text!.stringByReplacingOccurrencesOfString("'", withString: ""))
            accountInfoToPass.append(heightInTextField.text!.stringByReplacingOccurrencesOfString("''", withString: ""))
            accountInfoToPass.append(curWeightTextField.text!)
            accountInfoToPass.append(goalWeightTextField.text!)
            performSegueWithIdentifier("activitylevel", sender: self)
        }

    }
    
    /*
     ----------------------------------------------
     MARK: - PickerView Delegate/Datasource methods
     ----------------------------------------------
     */
    
    // Setting the number of components (columns) in the pickerview
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // Set the number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0
        {
            return pickOptionForHeightFt.count
        }
        
        else
        {
            return pickerOptionForHeightInches.count
        }
    }
    
    // Set title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0
        {
            return pickOptionForHeightFt[row]
        }
            
        else
        {
            return pickerOptionForHeightInches[row]
        }
    }
    
    // Updates the textfield when the picker view is selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0
        {
            heightFtTextField.text = pickOptionForHeightFt[row]
        }
        else
        {
            heightInTextField.text = pickerOptionForHeightInches[row]
        }
    }

    

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "activitylevel" {
            
            let activityLevelViewController: ActivityLevelViewController = segue.destinationViewController as! ActivityLevelViewController
            
            activityLevelViewController.accountInfoPassed = accountInfoToPass
            
        }
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
