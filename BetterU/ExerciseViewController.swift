//
//  ExerciseViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/17/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class ExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var logExerciseButton: UIButton!
    @IBOutlet var recommendMeButton: UIButton!
    @IBOutlet var myExercisesTable: UITableView!
    @IBOutlet var recommendedExercisesTable: UITableView!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var loggedExerciseKey = [String]()
    var recommendedExerciseDict = [String]()
    
    // Only calls and stores in the variable when the user has touched a row within the Exercise View Controller
    var workoutDescriptionPassed = ""
    var repsPerSetsPassed = ""
    var numberSetsPassed = ""
    var weightLbsPassed = ""
    var workoutLengthPassed = ""
    var workoutIntensityPassed = ""
    var hasTouchedRow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logExerciseButton.layer.cornerRadius = 8
        recommendMeButton.layer.cornerRadius = 8
        
        loggedExerciseKey = applicationDelegate.savedLoggedExercisesDict.allKeys as! [String]
    }

    // View will get updated with the correct recipe in the table
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        loggedExerciseKey = applicationDelegate.savedLoggedExercisesDict.allKeys as! [String]
        hasTouchedRow = false
        self.myExercisesTable.reloadData()
    }

    @IBAction func logExerciseButtonTapped(sender: UIButton)
    {
        performSegueWithIdentifier("LogExercise", sender: self)
    }
    
    @IBAction func recommendMeButtonTapped(sender: UIButton)
    {
        performSegueWithIdentifier("recommendExercise", sender: self)
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
        
        // Logged exercises table
        if tableView.tag == 1
        {
            return loggedExerciseKey.count
        }
        
        return recommendedExerciseDict.count
    }
    
    /*
     ---------------------------------
     MARK: - TableViewDelegate Methods
     ---------------------------------
     */
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row: Int = indexPath.row
        
        if tableView.tag == 1
        {
            let cell = myExercisesTable.dequeueReusableCellWithIdentifier("myExercisesCell")
            
            let exerciseKey = loggedExerciseKey[row]
            
            var descriptionOfExercise = applicationDelegate.savedLoggedExercisesDict[exerciseKey] as! [String]
            
            cell?.textLabel!.text = descriptionOfExercise[0]
            
            if descriptionOfExercise[1] == "" && descriptionOfExercise[2] == "" && descriptionOfExercise[3] == ""
            {
                cell?.detailTextLabel!.text = "\(descriptionOfExercise[4]) mins, intensity \(descriptionOfExercise[5])"
            }
            
            else if descriptionOfExercise[1] == ""
            {
                cell?.detailTextLabel!.text = "\(descriptionOfExercise[2]) Sets, \(descriptionOfExercise[3]) lbs, \(descriptionOfExercise[4]) mins, intensity \(descriptionOfExercise[5])"
            }
            else if descriptionOfExercise[2] == ""
            {
                cell?.detailTextLabel!.text = "\(descriptionOfExercise[1]) Reps, \(descriptionOfExercise[3]) lbs, \(descriptionOfExercise[4]) mins, intensity \(descriptionOfExercise[5])"
            }
            else if descriptionOfExercise[3] == ""
            {
                cell?.detailTextLabel!.text = "\(descriptionOfExercise[1]) Reps, \(descriptionOfExercise[2]) Sets, \(descriptionOfExercise[4]) mins, intensity \(descriptionOfExercise[5])"
            }
            
            else {
                cell?.detailTextLabel!.text = "\(descriptionOfExercise[1]) Reps, \(descriptionOfExercise[2]) Sets, \(descriptionOfExercise[3]) lbs, \(descriptionOfExercise[4]) mins, intensity \(descriptionOfExercise[5])"
            }
            
            return cell!
        }
        
        else
        {
            let cell = recommendedExercisesTable.dequeueReusableCellWithIdentifier("recommendedExercisesCell")

            
            return cell!
        }
    }
    
    /*
     -------------------------------------------------------------------
     Informs the table view delegate that the specified row is selected.
     -------------------------------------------------------------------
     */
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let row: Int = indexPath.row    // Identify the row number
        
        let exerciseKey = loggedExerciseKey[row]
        
        var descriptionOfExercise = applicationDelegate.savedLoggedExercisesDict[exerciseKey] as! [String]
        
        workoutDescriptionPassed = descriptionOfExercise[0]
        repsPerSetsPassed = descriptionOfExercise[1]
        numberSetsPassed = descriptionOfExercise[2]
        weightLbsPassed = descriptionOfExercise[3]
        workoutLengthPassed = descriptionOfExercise[4]
        workoutIntensityPassed = descriptionOfExercise[5]
        
        
        hasTouchedRow = true
        performSegueWithIdentifier("LogExercise", sender: self)
        
    }
    
    /*
     ------------------------
     MARK - Prepare For Segue
     ------------------------
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LogExercise"
        {
            let logExerciseViewController: LogExerciseViewController = segue.destinationViewController as! LogExerciseViewController
            
            logExerciseViewController.hasTouchedRows = self.hasTouchedRow
            logExerciseViewController.workoutDescriptionPassed = self.workoutDescriptionPassed
            logExerciseViewController.repsPerSetsPassed = self.repsPerSetsPassed
            logExerciseViewController.numberSetsPassed = self.numberSetsPassed
            logExerciseViewController.weightLbsPassed = self.weightLbsPassed
            logExerciseViewController.workoutLengthPassed = self.workoutLengthPassed
            logExerciseViewController.workoutIntensityPassed = self.workoutIntensityPassed
        }
    }


    
}
