//
//  CurrentChallengesAlertViewController.swift
//  BetterU
//
//  Created by Hung Vu on 5/1/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class CurrentChallengesAlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var currentChallengesArray = [[String]]()
    var pastChallengesArray = [[String]]()
    
    // Current Challenges Array
    var currentChallengeArray = [String]()
    var currentChallengePoints = [Int]()
    var currentChallengeType = [String]()
    
    // Pas challenges array
    var pastChallengeArray = [String]()
    var pastChallengePoints = [Int]()
    var pastChallengeType = [String]()
    
    var userId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId = applicationDelegate.userAccountInfo["id"] as! Int
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let currentChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Current Challenges"] as! [[String]]
        let pastChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Past Challenges"] as! [[String]]
        
        // Only execute if there are items in the current challenges dictionary
        if currentChallengesArrayFromPlist.count > 0
        {
            /* These actions executes by doing a loop within the dictionary and appends the item to the appropriate field */
            var j = 0
            while(j < currentChallengesArrayFromPlist[0].count)
            {
                currentChallengeArray.append(currentChallengesArrayFromPlist[0][j])
                j = j + 1
            }
            
            var k = 0
            while(k < currentChallengesArrayFromPlist[1].count)
            {
                currentChallengeType.append(currentChallengesArrayFromPlist[1][k])
                k = k + 1
            }
            
            var p = 0
            while(p < currentChallengesArrayFromPlist[2].count)
            {
                
                currentChallengePoints.append(Int(currentChallengesArrayFromPlist[2][p])!)
                p = p + 1
            }
            
        }
        
        // Only execute if the user has any items in the past challenges table
        if pastChallengesArrayFromPlist.count > 0
        {
            /* These actions executes by doing a loop within the dictionary and appends the item to the appropriate field */
            var j = 0
            while(j < pastChallengesArrayFromPlist[0].count)
            {
                pastChallengeArray.append(pastChallengesArrayFromPlist[0][j])
                j = j + 1
            }
            
            var k = 0
            while(k < pastChallengesArrayFromPlist[1].count)
            {
                pastChallengeType.append(pastChallengesArrayFromPlist[1][k])
                k = k + 1
            }
            
            var p = 0
            while(p < pastChallengesArrayFromPlist[2].count)
            {
                
                pastChallengePoints.append(Int(pastChallengesArrayFromPlist[2][p])!)
                p = p + 1
            }
        }
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.tableView.reloadData()
        })
        
        //print(applicationDelegate.savedChallengesDict)
        
    }
    
    func completeChallengeCall(challengeType: String)
    {
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.service.challenges.userindex/completeChallengeForUserId=\(userId)_\(challengeType)"
        
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
    }
    
    func vetoDailyChallengeCall(challengeType: String)
    {
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.service.challenges.userindex/vetoDailyChallengeForUserId=\(userId)_\(challengeType)"
        
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
    
    @IBAction func exitButtonTapped(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
     ----------------------------------------------
     MARK: - UITableViewDataSource Protocol Methods
     ----------------------------------------------
     */
    
    // Asks the data source to return the number of sections in the table view.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1  // We have only 1 section in our table view
    }
    
    // Asks the data source to return the number of rows in a given section of a table view.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Returns the amount of names in the current challenges (this will equal the actual current challenges amount)
        if currentChallengeArray.count > 0 {
            return currentChallengeArray.count
        }
        return 0
    }
    
    /*
     ---------------------------------
     MARK: - TableViewDelegate Methods
     ---------------------------------
     */
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row: Int = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("simpleLabelRow")! as UITableViewCell
        
        cell.textLabel!.text = currentChallengeArray[row]
        cell.detailTextLabel!.text = String(currentChallengePoints[row]) + " points (" + currentChallengeType[row] + ")"
        
        // Sets the image according to the type of challenge
        switch(currentChallengeType[row])
        {
            case "Cardio":
                cell.imageView!.image = UIImage(named: "cardioImage")
                break
                
            case "Lower":
                cell.imageView!.image = UIImage(named: "lowerBodyImage")
                break
                
            case "Upper":
                cell.imageView!.image = UIImage(named: "upperBodyImage")
                break
                
            case "Core":
                cell.imageView!.image = UIImage(named: "absIcon")
                break
                
            case "Weekly":
                cell.imageView!.image = UIImage(named: "weeklyChallengesIcon")
                break
                
            default:
                break
        }
        
        return cell
    }

    // When the user selects a row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var challengeName = ""
        var challengeType = ""
        var challengePoints = ""
        
        currentChallengesArray = self.applicationDelegate.savedChallengesDict["Current Challenges"] as! [[String]]
        
        let message = "Have you successfully completed this challenge?"
        
        let alertController = UIAlertController(title: "Complete Challenge", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        // When the user completed their challenge, their points will be awarded
        // Past challenges will be added at a row
        alertController.addAction(UIAlertAction(title: "Yes, it's completed", style: .Default, handler: { (action: UIAlertAction!) in
            
            challengeName = self.currentChallengeArray.removeAtIndex(indexPath.row)
            challengeType = self.currentChallengeType.removeAtIndex(indexPath.row)
            challengePoints = String(self.currentChallengePoints.removeAtIndex(indexPath.row))
            
            self.pastChallengeArray.append(challengeName)
            self.pastChallengeType.append(challengeType)
            self.pastChallengePoints.append(Int(challengePoints)!)
            
            // We remove everything from the pastChallengesArray before we start adding in new items to avoid
            // duplicates at various locatons.
            self.pastChallengesArray.removeAll(keepCapacity: false)
            
            // If there are items in the current challenges array, remove them at an index
            if self.currentChallengesArray.count > 0
            {
                self.currentChallengesArray[0].removeAtIndex(indexPath.row)
                self.currentChallengesArray[1].removeAtIndex(indexPath.row)
                self.currentChallengesArray[2].removeAtIndex(indexPath.row)
            }
            
            // After removing items from the currentChallengesArray, append new items onto the past array
            self.pastChallengesArray.append(self.pastChallengeArray)
            self.pastChallengesArray.append(self.pastChallengeType)
            
            /* This code grabs data from the pastChallengesPoints and convert every value into a String */
            let pastStringPointsArray = self.pastChallengePoints.map ({
                (number: Int) -> String in
                return String(number)
                
            })
            
            self.pastChallengesArray.append(pastStringPointsArray)
            self.completeChallengeCall(challengeType)
            
            // Sets the plist values
            self.applicationDelegate.savedChallengesDict.setValue(self.pastChallengesArray, forKey: "Past Challenges")
            self.applicationDelegate.savedChallengesDict.setValue(self.currentChallengesArray, forKey: "Current Challenges")
            
            //print(self.applicationDelegate.savedChallengesDict)
            //print(self.currentChallengesArray)
            
            UIView.transitionWithView(tableView,
                duration: 0.30,
                options: .TransitionCrossDissolve,
                animations:
                { () -> Void in
                    self.tableView.reloadData()
                },
                completion: nil);
        }))
        
        // When the user wants to remove (or veto) the challenge, then their removed challenge will be removed from the daily/weekly table
        // and the backend will let them grab a new one
        alertController.addAction(UIAlertAction(title: "Remove it", style: .Default, handler: { (action: UIAlertAction!) in
            self.currentChallengeArray.removeAtIndex(indexPath.row)
            challengeType = self.currentChallengeType.removeAtIndex(indexPath.row)
            self.currentChallengePoints.removeAtIndex(indexPath.row)
            
            if self.currentChallengesArray.count > 0
            {
                self.currentChallengesArray[0].removeAtIndex(indexPath.row)
                self.currentChallengesArray[1].removeAtIndex(indexPath.row)
                self.currentChallengesArray[2].removeAtIndex(indexPath.row)
            }
            
            self.applicationDelegate.savedChallengesDict.setValue(self.currentChallengesArray, forKey: "Current Challenges")
            
            self.vetoDailyChallengeCall(challengeType)
            
            UIView.transitionWithView(tableView,
                duration: 0.30,
                options: .TransitionCrossDissolve,
                animations:
                { () -> Void in
                    self.tableView.reloadData()
                },
                completion: nil);
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        
        // Present the alert controller by calling the presentViewController method
        self.presentViewController(alertController, animated: true, completion: nil)
        

    }
    
}
