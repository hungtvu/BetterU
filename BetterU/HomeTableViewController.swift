//
//  HomeTableViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/1/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var weightInLbs: Int = 800
    var tableViewRowHeight: CGFloat = 117.0
    var totalCaloriesBurned: Double = 0.0
    var totalMilesWalked: Double = 0.0
    var stepsCount: Int = 0
    
    var context: NSManagedObjectContext!
    
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Home"
        
        weightInLbs = applicationDelegate.userAccountInfo["User Weight"] as! Int
        print(applicationDelegate.userAccountInfo)
        
        HealthKitHelper().recentSteps() { steps, error in
            
            // Since there are 2112 steps in one mile, we will divide steps taken by 2112
            let milesFromSteps: Double = steps/2112
            
            // Calculate the amount of calories burned per mile
            // By multiplying the user's weight by 0.57, we can get that.
            // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
            let caloriesBurnedPerMile = 0.57 * Double(self.weightInLbs)
            
            // Divide the number of calories that are burned per mile by number of steps to walk a mile
            let caloriesPerStep = caloriesBurnedPerMile/2112
            
            // Calculating calories burned by multiplying the total steps to calories burned per steps
            let totalCaloriesBurnedFromSteps = steps * caloriesPerStep
            
            // Grabbing the necessary values and assigning it to a variable
            self.totalCaloriesBurned = round(totalCaloriesBurnedFromSteps * 10)/10
            self.totalMilesWalked = round(milesFromSteps * 100)/100
            self.stepsCount = Int(steps)
        }
        
       

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
            dispatch_async(dispatch_get_main_queue(),
            {
                self.tableView.reloadData()
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // There is only one section in the table
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // This method tells you how many rows there are in each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // Asks the table view delegate to return the height of a given row.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return tableViewRowHeight
    }
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    // This method asks the tableView to populate the prototype cells with the necessary information
    // The cells are all custom cells. We did it this way because some value items had different properties
    // such as, the steps taken row only required an integer instead of a float. 
    // Furthermore, making each cell custom from each other prevents unnecessary crash in the code. Before, we
    // used arrays of strings and double under the HealthKitHelper method, the app would crash due to it not
    // populating the indices of the array in time. When that happens, we will get an index out of bounds error.
    // Making each cell custom, we don't have to worry about populating data through the use of arrays.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let row: Int = indexPath.row
        
        // Populating the calories burned row
        if row == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Calories")! as! HomeTableViewCell
        
            // Grab the row count from the indexPath in the cell
            cell.thumbnailImage!.image = UIImage(named: "CaloriesBurnedIcon")
            cell.valueLabel!.text = String(totalCaloriesBurned)
            cell.metricLabel!.text = "Cal."
            
            return cell
        }
            
        // Populating the steps taken row
        else if row == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Steps")! as! StepsTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "StepsIcon")
            cell.valueLabel!.text = String(stepsCount)
            cell.metricLabel!.text = "Steps"
            
            return cell
        }
        
        // Populating te miles walked row
        else if row == 2
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Miles")! as! MilesTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "runningManIcon")
            cell.valueLabel!.text = String(totalMilesWalked)
            cell.metricLabel!.text = "Miles"
            
            return cell
        }
        
        // Populating the weight row
        else if row == 3
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Weight")! as! WeightTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "weightIcon")
            cell.valueLabel!.text = String(weightInLbs)
            cell.metricLabel!.text = "lbs"
            
            return cell
        }
        
        // Populating the caloric intake row
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("CaloricIntake")! as! CaloricIntakeTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "bananaIcon")
            cell.valueLabel!.text = String(0.0)
            cell.metricLabel!.text = "In"
            
            return cell
        }
    }
    
    
   
}