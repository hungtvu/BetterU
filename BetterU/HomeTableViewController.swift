//
//  HomeTableViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/1/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import HealthKit

class HomeTableViewController: UITableViewController {
    
    var thumbnailImages: [UIImage] = []
    var rowTitle: [String] = []
    var rowDetails: [Double] = []
    var stepsCount: Double = 0.0
    var metricStringArray: [String] = []
    var weightInLbs: Double = 800.0
    var tableViewRowHeight: CGFloat = 117.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        
        // Add images into the UIImage array
        thumbnailImages.append(UIImage(named: "CaloriesBurnedIcon")!)
        thumbnailImages.append(UIImage(named: "StepsIcon")!)
        thumbnailImages.append(UIImage(named: "runningManIcon")!)
        thumbnailImages.append(UIImage(named: "weightIcon")!)
        thumbnailImages.append(UIImage(named: "bananaIcon")!)
        
        // Add title for each row into the String arrays
        rowTitle.append("Calories Burned")
        rowTitle.append("Steps Taken")
        rowTitle.append("Miles Walked")
        rowTitle.append("Weight")
        rowTitle.append("Caloric Intake")
        
        // Add metrics for each row in the table
        metricStringArray.append("Cal.")
        metricStringArray.append("Steps")
        metricStringArray.append("Miles")
        metricStringArray.append("lbs")
        metricStringArray.append("In")
        
        
        HealthKitHelper().recentSteps() { steps, error in
            
            // Since there are 2112 steps in one mile, we will divide steps taken by 2112
            let milesFromSteps: Double = steps/2112
            
            // Calculate the amount of calories burned per mile
            // By multiplying the user's weight by 0.57, we can get that. 
            // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
            let caloriesBurnedPerMile = 0.57 * self.weightInLbs
            
            // Divide the number of calories that are burned per mile by number of steps to walk a mile
            let caloriesPerStep = caloriesBurnedPerMile/2112
            
            // Calculating calories burned by multiplying the total steps to calories burned per steps
            let totalCaloriesBurnedFromSteps = steps * caloriesPerStep
            
            self.rowDetails.append(round(totalCaloriesBurnedFromSteps)) // Calories Burned
            self.rowDetails.append(steps) // Steps taken
            
            self.rowDetails.append(round(milesFromSteps * 100)/100) // Miles taken
            
            self.rowDetails.append(self.weightInLbs) // Weight
            self.rowDetails.append(0) // Caloric Intake

        }
        
        
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
        return thumbnailImages.count
    }
    
    // Asks the table view delegate to return the height of a given row.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return tableViewRowHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Progress")! as! HomeTableViewCell
        
        // Grab the row count from the indexPath in the cell
        let row: Int = indexPath.row
    
        cell.thumbnailImage!.image = thumbnailImages[row]
        cell.titleLabel!.text = rowTitle[row]
        cell.valueLabel!.text = String(rowDetails[row])
        cell.metricLabel!.text = metricStringArray[row]
        
        return cell
    }
   
}