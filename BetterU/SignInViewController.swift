//
//  SignInViewController.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    
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
