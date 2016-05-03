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
    var recommendedExerciseKey = [String]()
    
    // Only calls and stores in the variable when the user has touched a row within the Exercise View Controller
    var workoutDescriptionPassed = ""
    var repsPerSetsPassed = ""
    var numberSetsPassed = ""
    var weightLbsPassed = ""
    var workoutLengthPassed = ""
    var workoutIntensityPassed = ""
    var hasTouchedRow = false
    
    // Variables to pass downstream for recommended exercises
    var recommendedWorkoutDescriptionToPass = ""
    var recommendedWorkoutNameToPass = ""
    var recommendedWorkoutMuscleGroupToPass = ""
    var recommendedWorkoutEquipmentToPass = ""
    var recommendedWorkoutExerciseIdToPass = 0
    var recommendedWorkoutPrimaryMuscleToPass = ""
    var recommendedWorkoutSecondaryMuscleToPass = ""
    var recommendedWorkoutMuscleImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logExerciseButton.layer.cornerRadius = 8
        recommendMeButton.layer.cornerRadius = 8
        
        loggedExerciseKey = applicationDelegate.savedLoggedExercisesDict.allKeys as! [String]
        recommendedExerciseKey = applicationDelegate.savedRecommendedExercisesDict.allKeys as! [String]

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    // View will get updated with the correct recipe in the table
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
    
        let rightButton = UIBarButtonItem(title: "Edit Exercise", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ExerciseViewController.showEditing(_:)))
        self.parentViewController?.navigationItem.rightBarButtonItem = rightButton
                
        loggedExerciseKey = applicationDelegate.savedLoggedExercisesDict.allKeys as! [String]
        recommendedExerciseKey = applicationDelegate.savedRecommendedExercisesDict.allKeys as! [String]
        hasTouchedRow = false
        self.myExercisesTable.reloadData()
        self.recommendedExercisesTable.reloadData()
    }
    
    @IBAction func logExerciseButtonTapped(sender: UIButton)
    {
        performSegueWithIdentifier("LogExercise", sender: self)
    }
    
    @IBAction func recommendMeButtonTapped(sender: UIButton)
    {
        performSegueWithIdentifier("recommendExercise", sender: self)
    }

    //----------------------
    // Allow Editing of Rows
    //----------------------
    
    // We allow each row of the table view to be editable, i.e., deletable or movable
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func showEditing(sender: UIBarButtonItem)
    {
        self.myExercisesTable.setEditing(!myExercisesTable.editing, animated: true)
        self.recommendedExercisesTable.setEditing(!recommendedExercisesTable.editing, animated: true)
        
        
        if(self.myExercisesTable.editing == true && self.recommendedExercisesTable.editing == true)
        {
            self.parentViewController?.navigationItem.rightBarButtonItem?.title = "Done"
        }
        else
        {
            self.parentViewController?.navigationItem.rightBarButtonItem?.title = "Edit Exercise"
        }
        
    }
    
    //---------------------
    // Delete Button Tapped
    //---------------------
    
    // This is the method invoked when the user taps the Delete button in the Edit mode
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Handle the Delete action
        if editingStyle == .Delete
        {
            if tableView.tag == 1
            {
                let exerciseKey = loggedExerciseKey[indexPath.row]
                loggedExerciseKey.removeAtIndex(indexPath.row)
                applicationDelegate.savedLoggedExercisesDict.removeObjectForKey(exerciseKey)
                self.myExercisesTable.reloadData()
            }
            
            else if tableView.tag == 2
            {
                let exerciseName = recommendedExerciseKey[indexPath.row]
                recommendedExerciseKey.removeAtIndex(indexPath.row)
                applicationDelegate.savedRecommendedExercisesDict.removeObjectForKey(exerciseName)
                self.recommendedExercisesTable.reloadData()
            }
        }
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
        
        return recommendedExerciseKey.count
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
            
            if applicationDelegate.savedLoggedExercisesDict.count > 0 {
            
                var descriptionOfExercise = applicationDelegate.savedLoggedExercisesDict[exerciseKey] as! [String]
                print(descriptionOfExercise)
                cell?.textLabel!.text = "\(descriptionOfExercise[0])"
                
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
            }
            else
            {
                self.myExercisesTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            
            return cell!
        }
        
        else
        {
            let cell = recommendedExercisesTable.dequeueReusableCellWithIdentifier("recommendedExercisesCell")! as UITableViewCell
            
            let exerciseName = recommendedExerciseKey[row]
            
            if applicationDelegate.savedRecommendedExercisesDict.count > 0
            {
                let exerciseInfo = applicationDelegate.savedRecommendedExercisesDict[exerciseName] as! [String]
                
                cell.textLabel!.text = "\(exerciseName) - \(exerciseInfo[1])"
                cell.detailTextLabel!.text = "\(exerciseInfo[2])"
            }
            else
            {
                self.recommendedExercisesTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            return cell
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
        
        if tableView.tag == 1
        {
            let exerciseKey = loggedExerciseKey[row]
            
            if applicationDelegate.savedLoggedExercisesDict.count > 0
            {
                var descriptionOfExercise = applicationDelegate.savedLoggedExercisesDict[exerciseKey] as! [String]
                
                workoutDescriptionPassed = descriptionOfExercise[0]
                repsPerSetsPassed = descriptionOfExercise[1]
                numberSetsPassed = descriptionOfExercise[2]
                weightLbsPassed = descriptionOfExercise[3]
                workoutLengthPassed = descriptionOfExercise[4]
                workoutIntensityPassed = descriptionOfExercise[5]
                hasTouchedRow = true
            }
            
            
            
            performSegueWithIdentifier("LogExercise", sender: self)
        }
        else if tableView.tag == 2
        {
            let exerciseName = recommendedExerciseKey[row]
            let exerciseInfo = applicationDelegate.savedRecommendedExercisesDict[exerciseName] as! [String]
            
            recommendedWorkoutNameToPass = exerciseName
            recommendedWorkoutMuscleGroupToPass = exerciseInfo[1]
            recommendedWorkoutEquipmentToPass = exerciseInfo[2]
            recommendedWorkoutDescriptionToPass = exerciseInfo[3]
            recommendedWorkoutExerciseIdToPass = Int(exerciseInfo[0])!
            recommendedWorkoutPrimaryMuscleToPass = exerciseInfo[4]
            recommendedWorkoutSecondaryMuscleToPass = exerciseInfo[5]
            recommendedWorkoutMuscleImage = UIImage(named: exerciseInfo[6])!
            
            hasTouchedRow = true
            
            performSegueWithIdentifier("showExerciseFromTable", sender: self)
        }
        
    }
    
    /*
     ------------------------
     MARK - Prepare For Segue
     ------------------------
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LogExercise" && hasTouchedRow
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
        
        else if segue.identifier == "showExerciseFromTable"
        {
            let parentExerciseView: ParentExerciseInfoViewController = segue.destinationViewController as! ParentExerciseInfoViewController
            
            parentExerciseView.hasGotFromTable = self.hasTouchedRow
            parentExerciseView.exerciseName = self.recommendedWorkoutNameToPass
            parentExerciseView.muscleGroupName = self.recommendedWorkoutMuscleGroupToPass
            parentExerciseView.equipmentName = self.recommendedWorkoutEquipmentToPass
            parentExerciseView.exerciseDescription = self.recommendedWorkoutDescriptionToPass
            parentExerciseView.exerciseId = self.recommendedWorkoutExerciseIdToPass
            parentExerciseView.primaryMuscleNameFromTable.append(self.recommendedWorkoutPrimaryMuscleToPass)
            parentExerciseView.secondaryMuscleNameFromTable.append(self.recommendedWorkoutSecondaryMuscleToPass)
            parentExerciseView.muscleGroupImage = self.recommendedWorkoutMuscleImage
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
