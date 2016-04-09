//
//  ActivityLevelViewController.swift
//  BetterU
//
//  Created by Michael Bulgakov on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

/* Current BUG: Checkmark is not disappearing when user first clicks on another row in the table. You need to
                select the table row again to make the checkmark disappear. */

class ActivityLevelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Initialize boolean arrays to allow logic in placing checkmarks next to each row selection
    var checkedInCurrentActivity = [Bool]()
    var checkedInGoalActivity = [Bool]()
    
    // Initialize variables to pass downstream to the AccountDetailsViewController
    var selectedPathForCurrentActivity = String()
    var selectedPathForGoalActivity = String()
    
    var currentActivityLevelToPass = 0
    var goalActivityLevelToPass = String()
    
    var accountInfoPass = [String]()
    var accountInfoPassed = [String]()
    
    // Initializing titles and subtitles for cells in different tables
    // The cellTitles are titles for the Current Activity Level table
    var cellTitles = ["Sedentary", "Lightly Active", "Active", "Very Active"]
    var cellSubtitles = ["I am exercising for less than 1 hour per week", "I am exercising for about 2-5 hours a week", "I am exercising for about 5-7 hours per week", "I am exercising for 8 or more hours per week"]
    
    var cellTitlesGoalActivity = ["Lightly Active", "Active", "Very Active"]
    var cellSubtitlesForGoalActivity = ["I want to spend some part of my day on my feet", "I want to spend more of my day being physical", "I want to spend most of my day getting physically healthier"]
    
    @IBOutlet var currentActivityLevelTableView: UITableView!
    @IBOutlet var goalActivityLevelTableView: UITableView!
    
    var currentActivityIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting boolean arrays to be the same size as the table
        checkedInCurrentActivity = [false, false, false, false]
        checkedInGoalActivity = [false, false, false]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    
    // Returns the number of sections in the tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // Returns the number of rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1
        {
            return 4
        }
        
        return 3
    }
    
    /*
     ------------------------------------
     Prepare and Return a Table View Cell
     ------------------------------------
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // grab row from indexpath
        let row: Int = indexPath.row
        
        if tableView.tag == 1 {
            
           let cell = currentActivityLevelTableView.dequeueReusableCellWithIdentifier("currentActivityCell",forIndexPath: indexPath) as UITableViewCell
            cell.textLabel!.text = cellTitles[row]
            cell.detailTextLabel!.text = cellSubtitles[row]
            if checkedInCurrentActivity[indexPath.row] == false {
                
                cell.accessoryType = .None
            }
            else if checkedInCurrentActivity[indexPath.row] == true {
                
                cell.accessoryType = .Checkmark
            }

            //cell.accessoryType = (lastSelectedIndexPath.row == row) ? .Checkmark : .None
            return cell
        }
        
        else {
            
            let cell = goalActivityLevelTableView.dequeueReusableCellWithIdentifier("goalActivityCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel!.text = cellTitlesGoalActivity[row]
            cell.detailTextLabel!.text = cellSubtitlesForGoalActivity[row]
            if checkedInGoalActivity[indexPath.row] == false {
                
                cell.accessoryType = .None
            }
            else if checkedInGoalActivity[indexPath.row] == true {
                
                cell.accessoryType = .Checkmark
            }

            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        // For the current activity level table view
        if tableView.tag == 1
        {
            selectedPathForCurrentActivity = cellTitles[indexPath.row]
            currentActivityIndex = indexPath.row
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if cell.accessoryType == .Checkmark
                {
                    cell.accessoryType = .None
                    checkedInCurrentActivity[indexPath.row] = false
                }
                else
                {
                    let newCell = tableView.cellForRowAtIndexPath(indexPath)
                    newCell!.accessoryType = .Checkmark
                    checkedInCurrentActivity[indexPath.row] = true
                }
            }
        }
        
        // For the goal activity level table view
        if tableView.tag == 2
        {
            selectedPathForGoalActivity = cellTitlesGoalActivity[indexPath.row]
      
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if cell.accessoryType == .Checkmark
                {
                    cell.accessoryType = .None
                    checkedInGoalActivity[indexPath.row] = false
                }
                else
                {
                    let newCell = tableView.cellForRowAtIndexPath(indexPath)
                    newCell!.accessoryType = .Checkmark
                    checkedInGoalActivity[indexPath.row] = true
                }
            }
        }
    }
    

    @IBAction func submitButtonTapped(sender: AnyObject) {
        
        if selectedPathForCurrentActivity == "" || selectedPathForGoalActivity == ""
        {
            self.showErrorMessage("BetterU needs to know your current and goal activity levels for best results.", errorTitle: "Required Entries Missing!")
            
            return 
        }
        
        currentActivityLevelToPass = currentActivityIndex
        goalActivityLevelToPass = selectedPathForGoalActivity
        accountInfoPass = accountInfoPassed
        performSegueWithIdentifier("accountdetails", sender: self)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "accountdetails" {
            
            let accountDetailsViewController: AccountDetailsViewController = segue.destinationViewController as! AccountDetailsViewController
            
            accountDetailsViewController.currentActivity = currentActivityIndex
            accountDetailsViewController.goalActivity = goalActivityLevelToPass
            accountDetailsViewController.accountInfoPassed = accountInfoPass
            
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
