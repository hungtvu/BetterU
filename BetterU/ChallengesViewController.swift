//
//  ChallengesViewController.swift
//  BetterU
//
//  Created by Mukund Katti on 4/25/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class ChallengesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var dailyChallengeButton: UIButton!
    
    
    @IBOutlet var currentChallengesTable: UITableView!
    
    @IBOutlet var weeklyChallengesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    var dailyChallenges: [String] = ["Run for 30 minutes"]
    
    var currentChallenges: [String] = []
    let weeklyChallenges = ["Run 10 miles", "Do 200 push ups"]
    
    
    @IBAction func dailyChallengeTapped(sender: UIButton) {

        
    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.isEqual(self.tableView) {
            return dailyChallenges.count
        }
        if tableView.isEqual(self.currentChallengesTable) {
            return currentChallenges.count
        }
        
        return weeklyChallenges.count
        
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if tableView.isEqual(self.tableView) {
            let cell: DailyChallengeCell = tableView.dequeueReusableCellWithIdentifier("DailyChallengeCell") as! DailyChallengeCell
            cell.challengeDescription.text! = "Run for 30 minutes"
            return cell
        }
        if tableView.isEqual(self.currentChallengesTable) {
            let cell: ChallengesCell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell") as! ChallengesCell
            cell.challengeTypeImg.image! = UIImage(named: "runningManIcon")!
            cell.challengeDescription.text! = currentChallenges[indexPath.row]
            return cell
        }
        let cell: WeeklyChallengeCell = tableView.dequeueReusableCellWithIdentifier("WeeklyChallengeCell") as! WeeklyChallengeCell
        if weeklyChallenges[indexPath.row] == "Do 200 push ups" {
            cell.challengeTypeImg.image! = UIImage(named:"upperBody")!
        }
        cell.challengeDescription.text! = weeklyChallenges[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView,
                     didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if !tableView.isEqual(self.currentChallengesTable) {
            
            if tableView.isEqual(self.weeklyChallengesTable) {
                let cell: WeeklyChallengeCell = tableView.dequeueReusableCellWithIdentifier("WeeklyChallengeCell") as! WeeklyChallengeCell
                cell.check.image = UIImage(named: "check")
                cell.backgroundColor = UIColor.lightGrayColor()
                currentChallenges.append(weeklyChallenges[indexPath.row])
                currentChallengesTable.reloadData()
                
            }else{
                let cell: DailyChallengeCell = tableView.dequeueReusableCellWithIdentifier("DailyChallengeCell") as! DailyChallengeCell
                cell.check.image = UIImage(named: "check")
                cell.backgroundColor = UIColor.lightGrayColor()
                currentChallenges.append(dailyChallenges[indexPath.row])
                currentChallengesTable.reloadData()
            }
        }else{
            
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local constant alertController
             */
            let alertController = UIAlertController(title: "Complete Challenge", message: "Did you successfully complete this challenge?", preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                self.currentChallenges.removeAtIndex(indexPath.row)
                self.currentChallengesTable.reloadData()
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
                self.currentChallenges.removeAtIndex(indexPath.row)
                self.currentChallengesTable.reloadData()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))

            
            // Present the alert controller by calling the presentViewController method
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        
        
    }
    

}
