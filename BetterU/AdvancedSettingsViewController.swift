//
//  AdvancedSettingsViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/4/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class AdvancedSettingsViewController: UIViewController {

    
    @IBOutlet var goalWeightTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var confirmNewPasswordTextField: UITextField!
    
    @IBOutlet var settingsTableView: UITableView!
    @IBOutlet var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
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
    
    // Number of rows in a given country (section) = Number of Cities in the given country (section)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let row = indexPath.row
        
        if row == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("pushNotifCell") as! PushNotificationTableViewCell
            
            cell.titleLabel!.text = "Push Notification"
            
            return cell
        }
        
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("setActLvlCell")! as UITableViewCell
            
            cell.textLabel!.text = "Set Activity Level"
            
            return cell
        }
        
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let row = indexPath.row
        
        if row == 1
        {
            performSegueWithIdentifier("setActivityLevel", sender: self)
        }
    }


}
