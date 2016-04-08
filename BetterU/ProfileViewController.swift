//
//  ProfileViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/4/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Initialize object references to the Label class
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var levelPercentLabel: UILabel!
    
    // Initialize object references to the ProgressView class
    @IBOutlet var progressView: UIProgressView!
    
    // Initializing buttons
    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet var addPhotoButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    
    // Initializing table
    @IBOutlet var settingsTableView: UITableView!
    
    var settingsTitleArray = [String]()
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Grabbing user information from the plist
        firstName = applicationDelegate.userAccountInfo["First Name"] as! String
        lastName = applicationDelegate.userAccountInfo["Last Name"] as! String
        email = applicationDelegate.userAccountInfo["Email"] as! String
        
        // Assigning label values
        firstNameLabel.text = firstName
        lastNameLabel.text = lastName
        emailLabel.text = email
        
        // Adding in rounded corners to the buttons
        editProfileButton.layer.cornerRadius = 8;
        logoutButton.layer.cornerRadius = 8;
        
        settingsTitleArray.append("Advanced Settings")
        settingsTitleArray.append("Contact Information")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editProfileButtonTapped(sender: UIButton)
    {
        self.performSegueWithIdentifier("EditProfile", sender: self)
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
    
    // Number of rows in the menu
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    //-----------------------------
    // Set Title for Section Header
    //-----------------------------
    
    // Set the table view section header
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "User Settings"
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsDetail")! as UITableViewCell
        
        let row = indexPath.row
        
        cell.textLabel!.text = settingsTitleArray[row]
        
        return cell
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Obtain the name of the row
        let rowName = settingsTitleArray[indexPath.row]
        
        if rowName == "Advanced Settings"
        {
            // Perform the segue named advancedSettingsView
            performSegueWithIdentifier("advancedSettingsView", sender: self)
        }
        
        else
        {
            // Perform the segue named contactInfoView
            performSegueWithIdentifier("contactInfoView", sender: self)
        }
        
        
    }
    
    
    // This method, when tapped, calls from the AppDelegate file and initiate the resetAppToFirstView() method
    // That method will assign a new view by grabbing the view's unique StoryBoard ID.
    @IBAction func logoutButtonTapped(sender: UIButton)
    {
        //self.performSegueWithIdentifier("SignInView", sender: self)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.resetAppToFirstView()
    }
    
}
