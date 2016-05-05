//
//  CustomAlertViewController.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/2016.
//  Copyright (c) 2016 BetterU LLC. All rights reserved.
//

import UIKit

class CustomAlertViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Stores the user's selected row to pass upstream
    var selection = ""
    
    // Passed from upstream to trigger a callback upon returning to upstream view controller
    var sender: CustomTabBarController!
    var sender2: RecipeInfoViewController!
    
    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: TableViewDelegate Methods
    
    // Disallow editing
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    // Disallow moving rows
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    // Handle row creation
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("simpleLabelRow")
        
        // Assign for simple labels
        switch(row) {
        case 0:
            cell!.textLabel!.text = "Breakfast"
            break
        case 1:
            cell!.textLabel!.text = "Lunch"
            break
        case 2:
            cell!.textLabel!.text = "Dinner"
            break
        case 3:
            cell!.textLabel!.text = "Snacks"
            break
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
            selection = "Breakfast"
            break
        case 1:
            selection = "Lunch"
            break
        case 2:
            selection = "Dinner"
            break
        case 3:
            selection = "Snacks"
            break
        default:
            selection = "Error"
            break
        }
        
        // Close and return to upstream control
        dismissViewControllerAnimated(true, completion: {
            
            // Set the selection upstream and call"segueToDetailViewController"
            if ((self.sender2) != nil) {
            self.sender2.selection = self.selection
            self.sender2.popToScheduleViewController()
            }
            
        })
    }
    
    // MARK: TableViewDataSource Methods
    
    // Fixed (4) number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    // MARK: IBOutlet to Button
    
    @IBAction func closeClicked(sender: UIButton) {
        
        // Close and return to upstream control
        dismissViewControllerAnimated(true, completion: nil)
    }
}

