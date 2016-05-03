//
//  ChallengesViewController.swift
//  BetterU
//
//  Created by Mukund Katti on 4/25/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire

class ChallengesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var sectionTitleArray = ["Current Challenges", "Daily Challenges", "Weekly Challenges", "Past Challenges"]
    var userId = 0
    
    // Daily Challenges arrays
    var dailyChallengeArray = [String]()
    var dailyChallengePoints = [Int]()
    var dailyChallengeType = [String]()
    
    // Weekly Challenges Arrays
    var weeklyChallengeArray = [String]()
    var weeklyChallengePoints = [Int]()
    
    // Current Challenges Array
    var currentChallengeArray = [String]()
    var currentChallengePoints = [Int]()
    var currentChallengeType = [String]()
    
    // Pas challenges array
    var pastChallengeArray = [String]()
    var pastChallengePoints = [Int]()
    var pastChallengeType = [String]()
    
    var sectionSelected = [Bool]()
    
    var currentChallengesArray = [[String]]()
    var pastChallengesArray = [[String]]()
    
    var refreshControl: UIRefreshControl!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = applicationDelegate.userAccountInfo["id"] as! Int
        createUserChallengesData()
        
        //initialize boolean array to false
        sectionSelected.append(false)
        sectionSelected.append(false)
        sectionSelected.append(false)
        sectionSelected.append(false)
        
        if (dailyChallengeArray.count == 1)
        {
            parseDailyChallengesJson(1)
        }
        
        if (dailyChallengeArray.count == 0)
        {
            parseDailyChallengesJson(0)
        }
        
        if (weeklyChallengeArray.count < 1)
        {
            parseWeeklyChallengesJson()
        }
        
        // Grabs the current and past challenges info from the plist
        var currentChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Current Challenges"] as! [[String]]
        var pastChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Past Challenges"] as! [[String]]
        
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

        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, 20, 20))
        refreshControl.tintColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(ChallengesViewController.reloadTable(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        refreshControl.subviews[0].frame = CGRectMake(screenWidth * 0.25, 7, 20, 20)


     
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // Grabs the current and past challenges info from the plist
        var currentChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Current Challenges"] as! [[String]]
        var pastChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Past Challenges"] as! [[String]]
        
        currentChallengeArray.removeAll(keepCapacity: false)
        currentChallengePoints.removeAll(keepCapacity: false)
        currentChallengeType.removeAll(keepCapacity: false)
        
        pastChallengeArray.removeAll(keepCapacity: false)
        pastChallengePoints.removeAll(keepCapacity: false)
        pastChallengeType.removeAll(keepCapacity: false)
        
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
        
        if (self.dailyChallengeArray.count > 1)
        {
            // If daily challenges have duplicates
            while (self.dailyChallengeArray[0] == self.dailyChallengeArray[1])
            {
                self.dailyChallengeArray.removeAtIndex(1)
                self.dailyChallengeType.removeAtIndex(1)
                self.dailyChallengePoints.removeAtIndex(1)
                self.parseDailyChallengesJson(1)
            }
        }
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.tableView.reloadData()
        })
    }
    
    func reloadTable(sender: AnyObject)
    {
        // Grabs the current and past challenges info from the plist
        var currentChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Current Challenges"] as! [[String]]
        var pastChallengesArrayFromPlist = applicationDelegate.savedChallengesDict["Past Challenges"] as! [[String]]
        
        currentChallengeArray.removeAll(keepCapacity: false)
        currentChallengePoints.removeAll(keepCapacity: false)
        currentChallengeType.removeAll(keepCapacity: false)
        
        pastChallengeArray.removeAll(keepCapacity: false)
        pastChallengePoints.removeAll(keepCapacity: false)
        pastChallengeType.removeAll(keepCapacity: false)
        
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
        
        if (weeklyChallengeArray.count < 1)
        {
            parseWeeklyChallengesJson()
        }
        
        if (dailyChallengeArray.count == 1)
        {
            parseDailyChallengesJson(1)
        }
        
        if (dailyChallengeArray.count == 0)
        {
            parseDailyChallengesJson(0)
        }
        
        if (self.dailyChallengeArray.count > 1)
        {
            // If daily challenges have duplicates
            while (self.dailyChallengeArray[0] == self.dailyChallengeArray[1])
            {
                self.dailyChallengeArray.removeAtIndex(1)
                self.dailyChallengeType.removeAtIndex(1)
                self.dailyChallengePoints.removeAtIndex(1)
                self.parseDailyChallengesJson(1)
            }
        }

        dispatch_async(dispatch_get_main_queue(),
        {
            self.tableView.reloadData()
            
            if (self.refreshControl.refreshing)
            {
                self.refreshControl.endRefreshing()
            }
        
        })
    }
    
    func createUserChallengesData()
    {
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.service.challenges.userindex/createIndicesForUserId=\(userId)"
        
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
                
                if (dailyChallengeArray.count < 2)
                {
                    dailyChallengeArray.append(jsonData["description"] as! String)
                    dailyChallengePoints.append(jsonData["pointsAwarded"] as! Int)
                    dailyChallengeType.append(jsonData["challengeType"] as! String)
                }
                
                
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
    
    func parseDailyChallengesJson(limit: Int)
    {
        var i = limit
        while (i < 2) {
            // Instantiate an API URL to return the JSON data
            let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.service.challenges.userindex/setNextDailyChallengeForUserId=\(userId)"
            
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
                    
                    dailyChallengeArray.append(jsonData["description"] as! String)
                    dailyChallengePoints.append(jsonData["pointsAwarded"] as! Int)
                    dailyChallengeType.append(jsonData["challengeType"] as! String)
                    
                    
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
            i = i + 1
        }
    }
    
    func parseWeeklyChallengesJson()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.service.challenges.userindex/setNextWeeklyChallengeForUserId=\(userId)"
        
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
                
                //print(jsonData)
                
                weeklyChallengeArray.append(jsonData["description"] as! String)
                weeklyChallengePoints.append(jsonData["pointsAwarded"] as! Int)
                
                
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24.0
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if pastChallengeArray.count == 0 {
            return 3
        }
        return 4
    }
    
    
    // Displays the amount of rows in the section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sectionSelected[section]{
            switch section {
            case 0:
                return currentChallengeArray.count + 1
            case 1:
                return dailyChallengeArray.count + 1
            case 2:
                return weeklyChallengeArray.count + 1
            case 3:
                return pastChallengeArray.count + 1
            default:
                break;
            }
            
        }
        return 1
    }
    
    // Displays the cell information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        
        if row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell!
            cell.headerTitle.text = sectionTitleArray[section]
            return cell
        }
        
        if sectionSelected[section] {
            switch section {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("CurrentChallengeCell") as! CurrentChallengeCell!
                cell.challengeName.text = currentChallengeArray[abs(row - 1)]
                cell.pointDescription.text = String(currentChallengePoints[abs(row - 1)]) + " points (" + currentChallengeType[abs(row - 1)] + ")"
                
                switch(currentChallengeType[abs(row - 1)])
                {
                case "Cardio":
                    cell.challengeTypeImg.image = UIImage(named: "cardioImage")
                    break
                    
                case "Lower":
                    cell.challengeTypeImg.image = UIImage(named: "lowerBodyImage")
                    break
                    
                case "Upper":
                    cell.challengeTypeImg.image = UIImage(named: "upperBodyImage")
                    break
                    
                case "Core":
                    cell.challengeTypeImg.image = UIImage(named: "absIcon")
                    break
                    
                case "Weekly":
                    cell.challengeTypeImg.image = UIImage(named: "weeklyChallengesIcon")
                    break
                    
                default:
                    break
                }
                
                return cell
                
            case 1: // Daily challenges
                let cell = tableView.dequeueReusableCellWithIdentifier("RegularChallengeCell") as! RegularChallengeCell
                cell.challengeName.text = dailyChallengeArray[abs(row - 1)]
                cell.pointDescription.text = String(dailyChallengePoints[abs(row - 1)]) + " points (" + dailyChallengeType[abs(row - 1)] + ")"
                
                switch(dailyChallengeType[abs(row - 1)])
                {
                case "Cardio":
                    cell.challengeTypeImg.image = UIImage(named: "cardioImage")
                    break
                    
                case "Lower":
                    cell.challengeTypeImg.image = UIImage(named: "lowerBodyImage")
                    break
                    
                case "Upper":
                    cell.challengeTypeImg.image = UIImage(named: "upperBodyImage")
                    break
                    
                case "Core":
                    cell.challengeTypeImg.image = UIImage(named: "absIcon")
                    break
                    
                default:
                    break
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("RegularChallengeCell") as! RegularChallengeCell
                cell.challengeName.text = weeklyChallengeArray[abs(row - 1)]
                cell.pointDescription.text = String(weeklyChallengePoints[abs(row - 1)]) + " points"
                
                cell.challengeTypeImg.image = UIImage(named: "weeklyChallengesIcon")
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier("CurrentChallengeCell") as! CurrentChallengeCell
                cell.challengeName.text = pastChallengeArray[abs(row - 1)]
                cell.pointDescription.text = String(pastChallengePoints[abs(row - 1)]) + " points"
                
                switch(pastChallengeType[abs(row - 1)])
                {
                case "Cardio":
                    cell.challengeTypeImg.image = UIImage(named: "cardioImage")
                    break
                    
                case "Lower":
                    cell.challengeTypeImg.image = UIImage(named: "lowerBodyImage")
                    break
                    
                case "Upper":
                    cell.challengeTypeImg.image = UIImage(named: "upperBodyImage")
                    break
                    
                case "Core":
                    cell.challengeTypeImg.image = UIImage(named: "absIcon")
                    break
                    
                case "Weekly":
                    cell.challengeTypeImg.image = UIImage(named: "weeklyChallengesIcon")
                    break
                    
                default:
                    break
                }
                
                return cell
                
            default:
                break
            }
        }
        
        
        //code should never reach here
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrentChallengeCell") as! CurrentChallengeCell!
        return cell
        
    }
    
    // When the user selects a row
    func tableView(tableView: UITableView,
                   didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        // When the user clicks on a section header, the menu will drop down
        if indexPath.row == 0 {
            
            sectionSelected[indexPath.section] = !sectionSelected[indexPath.section]
            
            //let result = closeOtherSections(indexPath.section)
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        }
            
        else
        {
            // Grabs section number
            let section: Int = indexPath.section
            
            var challengeName = ""
            var challengeType = ""
            var challengePoints = ""
            
            // Current challenge cell
            if section == 0
            {
                let message = "Have you successfully completed this challenge?"
                
                let alertController = UIAlertController(title: "Complete Challenge", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                
                // Create a UIAlertAction object and add it to the alert controller
                // When the user completed their challenge, their points will be awarded
                // Past challenges will be added at a row
                alertController.addAction(UIAlertAction(title: "Yes, it's completed", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    challengeName = self.currentChallengeArray.removeAtIndex(indexPath.row - 1)
                    challengeType = self.currentChallengeType.removeAtIndex(indexPath.row - 1)
                    challengePoints = String(self.currentChallengePoints.removeAtIndex(indexPath.row - 1))
                    
                    self.pastChallengeArray.append(challengeName)
                    self.pastChallengeType.append(challengeType)
                    self.pastChallengePoints.append(Int(challengePoints)!)
                    
                    // We remove everything from the pastChallengesArray before we start adding in new items to avoid
                    // duplicates at various locatons.
                    self.pastChallengesArray.removeAll(keepCapacity: false)
                    
                    // If there are items in the current challenges array, remove them at an index
                    if self.currentChallengesArray.count > 0
                    {
                        self.currentChallengesArray[0].removeAtIndex(indexPath.row - 1)
                        self.currentChallengesArray[1].removeAtIndex(indexPath.row - 1)
                        self.currentChallengesArray[2].removeAtIndex(indexPath.row - 1)
                        
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
                    
                    // Sets the plist values
                    self.applicationDelegate.savedChallengesDict.setValue(self.pastChallengesArray, forKey: "Past Challenges")
                    self.applicationDelegate.savedChallengesDict.setValue(self.currentChallengesArray, forKey: "Current Challenges")
                    
                    if (challengeType == "Weekly" && self.weeklyChallengeArray.count < 1)
                    {
                        self.completeChallengeCall(challengeType)
                        self.parseWeeklyChallengesJson()
                    }
                    else
                    {
                        if (self.dailyChallengeArray.count < 2)
                        {
                            self.completeChallengeCall(challengeType)
                            self.parseDailyChallengesJson(1)
                        }
                    }
                    
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
                    self.currentChallengeArray.removeAtIndex(indexPath.row - 1)
                    challengeType = self.currentChallengeType.removeAtIndex(indexPath.row - 1)
                    self.currentChallengePoints.removeAtIndex(indexPath.row - 1)
                    
                    if self.currentChallengesArray.count > 0
                    {
                        self.currentChallengesArray[0].removeAtIndex(indexPath.row - 1)
                        self.currentChallengesArray[1].removeAtIndex(indexPath.row - 1)
                        self.currentChallengesArray[2].removeAtIndex(indexPath.row - 1)
                    }
                    
                    self.applicationDelegate.savedChallengesDict.setValue(self.currentChallengesArray, forKey: "Current Challenges")

                    self.vetoDailyChallengeCall(challengeType)
                    
                    if (challengeType == "Weekly" && self.weeklyChallengeArray.count < 1)
                    {
                        self.parseWeeklyChallengesJson()
                    }
                    
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
                
                // Daily challenges cell
            else if section == 1
            {
                
                let message = "Would you like to accept this challenge?"
                
                let alertController = UIAlertController(title: "Daily Challenge", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                
                // Create a UIAlertAction object and add it to the alert controller
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    // Removes the daily challenges from the index
                    challengeName = self.dailyChallengeArray.removeAtIndex(indexPath.row - 1)
                    challengeType = self.dailyChallengeType.removeAtIndex(indexPath.row - 1)
                    challengePoints += String(self.dailyChallengePoints.removeAtIndex(indexPath.row - 1))
                    
                    self.currentChallengeArray.append(challengeName)
                    self.currentChallengeType.append(challengeType)
                    self.currentChallengePoints.append(Int(challengePoints)!)
                    
                    self.currentChallengesArray.removeAll(keepCapacity: false)
                    self.currentChallengesArray.append(self.currentChallengeArray)
                    self.currentChallengesArray.append(self.currentChallengeType)
                    
                    let stringArray = self.currentChallengePoints.map(
                    {
                        (number: Int) -> String in
                        return String(number)
                    })
                    
                    self.currentChallengesArray.append(stringArray)
                    
                    self.applicationDelegate.savedChallengesDict.setValue(self.currentChallengesArray, forKey: "Current Challenges")
                    
                    self.sectionSelected[0] = true
                    
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
                
            // Weekly challenges cell
            else if section == 2
            {
                
                let message = "Would you like to accept this weekly challenge? Please be aware that these are harder, but provide more reward."
                
                let alertController = UIAlertController(title: "Weekly Challenge", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                
                // Create a UIAlertAction object and add it to the alert controller
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    // Removes the daily challenges from the index
                    challengeName = self.weeklyChallengeArray.removeAtIndex(indexPath.row - 1)
                    challengeType = "Weekly"
                    challengePoints = String(self.weeklyChallengePoints.removeAtIndex(indexPath.row - 1))
                    
                    self.currentChallengeArray.append(challengeName)
                    self.currentChallengeType.append(challengeType)
                    self.currentChallengePoints.append(Int(challengePoints)!)
                    
                    self.currentChallengesArray.removeAll(keepCapacity: false)
                    self.currentChallengesArray.append(self.currentChallengeArray)
                    self.currentChallengesArray.append(self.currentChallengeType)
                    
                    let stringArray = self.currentChallengePoints.map(
                    {
                        (number: Int) -> String in
                        return String(number)
                    })
                    
                    self.currentChallengesArray.append(stringArray)
                    
                    self.applicationDelegate.savedChallengesDict.setValue(self.currentChallengesArray, forKey: "Current Challenges")
                    
                    self.sectionSelected[0] = true
                    //self.parseWeeklyChallengesJson()
                    
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
        
    }
}
