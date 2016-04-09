//
//  AgeGenderViewController.swift
//  BetterU
//
//  Created by Michael Bulgakov on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class AgeGenderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    
    var accountInfoToPass = [String]()
    
    var pickOption = [String]()
    
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adds the age of the picker option from 13 to 99
        var i = 13;
        while (i < 99)
        {
            pickOption.append(String(i))
            i = i + 1
        }
        
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
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
        ageTextField.inputView = pickerView
        
        // Adds the toolbar to the textfield on top of the pickerview
        ageTextField.inputAccessoryView = toolBar
    
    }
    
    // This method is called when the user taps Return on the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Deactivate the text field and remove the keyboard
        textField.resignFirstResponder()
        
        return true
    }

    
    /*
     --------------------------------------------------
     MARK: - Toolbar actions with the press of a button
     --------------------------------------------------
     */
    func donePicker(sender: UIPickerView)
    {
        ageTextField.resignFirstResponder()
    }
    
    func cancelPicker(sender: UIPickerView)
    {
        ageTextField!.text = ""
        ageTextField.resignFirstResponder()
    }
    
    /*
     ----------------------------------------------
     MARK: - PickerView Delegate/Datasource methods
     ----------------------------------------------
     */
    
    // Setting the number of components in the pickerview
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Set the number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    // Set title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }

    // Updates the textfield when the picker view is selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ageTextField.text = pickOption[row]
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func maleButtonTapped(sender: UIButton) {
        if ageTextField.text!.isEmpty || firstNameTextField.text!.isEmpty || lastNameTextField.text!.isEmpty
        {
            self.showErrorMessage("Please fill out all require information.", errorTitle: "Missing Entries!")
            return
        }
        
        accountInfoToPass = [firstNameTextField.text!, lastNameTextField.text!, ageTextField.text!, "M"]
        performSegueWithIdentifier("heightandweight", sender: self)
    }
    
    @IBAction func femaleButtonTapped(sender: UIButton) {
        if ageTextField.text!.isEmpty || firstNameTextField.text!.isEmpty || lastNameTextField.text!.isEmpty
        {
            self.showErrorMessage("Please fill out all require information.", errorTitle: "Missing Entries!")
            return
        }
        
        accountInfoToPass = [firstNameTextField.text!, lastNameTextField.text!, ageTextField.text!, "F"]
        performSegueWithIdentifier("heightandweight", sender: self)

    }
    
    @IBAction func backButtonTapped(sender: UIBarButtonItem)
    {
        // Grabs the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Grabs the view controller from the storyboard ID
        let signInViewcontroller = storyboard.instantiateViewControllerWithIdentifier("SignInView") as! SignInViewController
        
        // Presents the previous view controller
        self.presentViewController(signInViewcontroller, animated: true, completion: nil)
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "heightandweight" {
            
            let heightWeightViewController: HeightWeightViewController = segue.destinationViewController as! HeightWeightViewController
            
            heightWeightViewController.accountInfoPassed = accountInfoToPass
            
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
            
            // If firstNameTextField is first responder and the user did not touch the firstNameTextField
            if firstNameTextField.isFirstResponder() && (touch.view != firstNameTextField) {
                
                // Make firstNameTextField to be no longer the first responder.
                firstNameTextField.resignFirstResponder()
            }
            
            if lastNameTextField.isFirstResponder() && (touch.view != lastNameTextField) {
                
                // Make passwordTextField to be no longer the first responder.
                lastNameTextField.resignFirstResponder()
            }
            
            
            
        }
        super.touchesBegan(touches, withEvent:event)
    }



}
