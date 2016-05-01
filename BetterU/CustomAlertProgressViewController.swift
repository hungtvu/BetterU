//
//  CustomAlertProgressViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/26/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class CustomAlertProgressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var progressTableView: UITableView!
    
    var selection = ""
    
    // Passed from upstream to trigger a callback upon returning to upstream view controller
    var sender: CustomTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonTapped(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // Handle row creation
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        //        var cell = tableView.dequeueReusableCellWithIdentifier("simpleLabelRow") as UITableViewCell!
        let cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("simpleLabelRow")
        
        // Assign for simple labels
        switch(row) {
        case 0:
            cell!.textLabel!.text = "Calories Burned"
            break
        case 1:
            cell!.textLabel!.text = "Steps Taken"
            break
        case 2:
            cell!.textLabel!.text = "Miles Walked"
            break
        case 3:
            cell!.textLabel!.text = "Weight"
            break
        case 4:
            cell!.textLabel!.text = "Caloric Intake"
        default:
            cell!.textLabel!.text = "Error"
            break
        }
        
        return cell!
    }
    
    // Handle row selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        // Return the label value of the selected row
        switch(row) {
        case 0:
            selection = "Calories Burned"
            break
        case 1:
            selection = "Steps Taken"
            break
        case 2:
            selection = "Miles Walked"
            break
        case 3:
            selection = "Weight"
            break
        case 4:
            selection = "Caloric Intake"
            break
        default:
            selection = "Error"
            break
        }
        
        // Close and return to upstream control
        dismissViewControllerAnimated(true, completion: {
            
            // Set the selection upstream and call "segueToDetailViewController"
            if ((self.sender) != nil) {
                if self.selection == "Calories Burned"
                {
                    self.sender.selection = self.selection
                    self.sender.segueToCaloriesBurnedProgressView()
                }
                else if self.selection == "Steps Taken"{
                    self.sender.selection = self.selection
                    self.sender.segueToStepsTakenProgressView()
                }
                else if self.selection == "Miles Walked"{
                    self.sender.selection = self.selection
                    self.sender.segueToMilesWalkedProgressView()
                }
                else if self.selection == "Weight"{
                    self.sender.selection = self.selection
                    self.sender.segueToWeightProgressView()
                }
                else {
                    self.sender.selection = self.selection
                    self.sender.segueToMilesWalkedProgressView()
                }
            }
        })
    }
    
    // MARK: TableViewDataSource Methods
    
    // Fixed (5) number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }

}
