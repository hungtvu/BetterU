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

}
