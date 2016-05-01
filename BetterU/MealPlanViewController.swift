//
//  MealPlanViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

/* MAJOR BUG: Users cannot move rows between sections without causing crashes or duplications of items. Users can however move within their own sections fine. */

class MealPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var logCaloriesButton: UIButton!
    @IBOutlet var recommendFoodButton: UIButton!
    @IBOutlet var mealScheduleTableView: UITableView!
    
    var sectionTypeArray = [String]()
    var nutritionDataArray = [String]()
    var nutritionDataString = String()
    
    let yummylyAppID = "21dfe224"
    let yummlyAPIKey = "ce3e5c566e575985f6c879283813c0d2"

    var recipeName = ""
    var recipeImageUrl = ""
    var servings = 0
    var totalTime = ""
    var calories = 0
    var recipeUrl = ""
    
    var recipeIdBreakfastArray = [String]()
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var editButtonTable = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding in rounded corners to the buttons
        logCaloriesButton.layer.cornerRadius = 8;
        recommendFoodButton.layer.cornerRadius = 8;
        
        sectionTypeArray = applicationDelegate.savedRecipesDict.allKeys as! [String]
        
        // Sort the selection names within itself in alphabetical order
        sectionTypeArray.sortInPlace { $0 < $1 }
        
    }
    
    // View will get updated with the correct recipe in the table
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        
        let leftButton = UIBarButtonItem(title: "Edit Meal", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MealPlanViewController.showEditing(_:)))
        self.parentViewController?.navigationItem.leftBarButtonItem = leftButton

        mealScheduleTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logCaloriesButtonTapped(sender: UIButton)
    {
        self.performSegueWithIdentifier("showLogCaloriesView", sender: self)
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
        self.mealScheduleTableView.setEditing(!mealScheduleTableView.editing, animated: true)
        
        if(self.mealScheduleTableView.editing == true)
        {
            self.parentViewController?.navigationItem.leftBarButtonItem?.title = "Done"
        }
        else
        {
            self.parentViewController?.navigationItem.leftBarButtonItem?.title = "Edit Meal"
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
            // Obtain the section of the recipe to be deleted
            let sectionOfRecipeToBeDeleted = sectionTypeArray[indexPath.section]
            
            // Obtain the list of recipes from each section
            let recipes: AnyObject? = applicationDelegate.savedRecipesDict[sectionOfRecipeToBeDeleted]
            
            // Typecast the anyobject to a swift array
            var recipesToBeDeleted = recipes! as! [[String]]
            
            // Delete the identified recipe at row
            recipesToBeDeleted.removeAtIndex(indexPath.row)
            
            // Update new list of recipes
            applicationDelegate.savedRecipesDict.setValue(recipesToBeDeleted, forKey: sectionOfRecipeToBeDeleted)
            
            self.mealScheduleTableView.reloadData()
        }
    }

    //---------------------------
    // Movement of Row Attempted
    //---------------------------
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    {
        // Obtain the section of the recipe to be deleted
        let sectionOfRecipe = sectionTypeArray[fromIndexPath.section]
        
        // Obtain the list of recipes from each section
        let recipes: AnyObject? = applicationDelegate.savedRecipesDict[sectionOfRecipe]
        
        // Typecast the anyobject to a swift array
        var recipesToBeMoved = recipes as! [[String]]
        
        // Row number to move FROM
        let rowNumberFrom = fromIndexPath.row
        
        // Row number to move TO
        let rowNumberTo = toIndexPath.row
        
        // Section number to move FROM
        let sectionNumberFrom = fromIndexPath.section
        
        // Section number to move TO
        let sectionNumberTo = toIndexPath.section
        
        // If the recipe cells are moving outside of their sections
        if sectionNumberFrom != sectionNumberTo
        {
            // Stores the recipe that is to be moved onto another variable
            let recipeNameToMove = recipesToBeMoved[rowNumberFrom]
            
            // Initialize the section name
            let sectionOfRecipeFrom = sectionTypeArray[sectionNumberFrom]
            let sectionOfRecipeTo = sectionTypeArray[sectionNumberTo]
            
            // Initialize local variables to grab the arrays of each section
            var recipesToBeMovedFrom = [[String]]()
            var recipesToBeMovedTo = [[String]]()
            
            // Grab the double array of strings for the section that the recipe is moving FROM
            if let recipesValuesFrom = applicationDelegate.savedRecipesDict[sectionOfRecipeFrom] as? [[String]]
            {
                recipesToBeMovedFrom = recipesValuesFrom
            }
    
            // Grab the double array of strings for the section that the recipe is moving TO
            if let recipesToValueArray = applicationDelegate.savedRecipesDict[sectionOfRecipeTo] as? [[String]]
            {
                recipesToBeMovedTo = recipesToValueArray
                
                // Inserts the original recipe to the section it is moving to
                recipesToBeMovedTo.insert(recipeNameToMove, atIndex: rowNumberTo)
                
                // Then removes that recipe completely from the row it was moved from
                recipesToBeMovedFrom.removeAtIndex(rowNumberFrom)
            }
            
            // Sets the value inside the dictionary and saves its data from the array
            applicationDelegate.savedRecipesDict.setValue(recipesToBeMovedFrom, forKey: sectionOfRecipeFrom)
            applicationDelegate.savedRecipesDict.setValue(recipesToBeMovedTo, forKey: sectionOfRecipeTo)
            
            // Additional cleanup (may not be necessary, but just in case)
            /* If there are no more recipes that was in its previous section, then remove the whole key from the dictionary and reinsert that key as an empty array. */
            if recipesToBeMovedFrom.count == 0
            {
                applicationDelegate.savedRecipesDict.removeObjectForKey(sectionOfRecipeFrom)
                applicationDelegate.savedRecipesDict.setObject([], forKey: sectionOfRecipeFrom)
            }
        }
        
        // Moving within sections
        else if rowNumberFrom != rowNumberTo
        {
        
            // Recipe to move:
            let recipeNameToMove = recipesToBeMoved[rowNumberFrom]
            
            // If movement is from lower part of the list to upper part
            if rowNumberFrom > rowNumberTo
            {
                recipesToBeMoved.insert(recipeNameToMove, atIndex: rowNumberTo)
                recipesToBeMoved.removeAtIndex(rowNumberFrom + 1)
            }
            else
            {
                // Movement is from upper part to lower part
                recipesToBeMoved.insert(recipeNameToMove, atIndex: rowNumberTo + 1)
                recipesToBeMoved.removeAtIndex(rowNumberFrom)
            }

            applicationDelegate.savedRecipesDict.setValue(recipesToBeMoved, forKey: sectionOfRecipe)
        
        }
        
        

    }
    
    //-----------------------
    // Allow Movement of Rows
    //-----------------------
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    
    // Each table view section corresponds to a country
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sectionTypeArray.count
    }
    
    //---------------------------------
    // Return Number of Rows in Section
    //---------------------------------
    
    // Number of rows in a given meal
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Obtain name of selection
        let selectionName = sectionTypeArray[section]
        
        // Obtain recipe names of each selection
        let recipeArray: AnyObject? = applicationDelegate.savedRecipesDict[selectionName]
        
        // Checks if there is something in the dictionary first
        if recipeArray != nil {
            
            // Typecast to AnyObject to Swift array of array of strings
            if let recipeArraysInEachSelection = recipeArray! as? [[String]]
            {
                return recipeArraysInEachSelection.count
            }
        }
        
        // If there isn't, then just return 0 rows
        return 0
    }
    
    //-----------------------------
    // Set Title for Section Header
    //-----------------------------
    
    // Set the table view section header
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTypeArray[section]
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell", forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        let section = indexPath.section
        
        // Obtain type of meal - the section
        let mealType = sectionTypeArray[section]
        
        // obtain recipe names
        let recipeInfo: AnyObject? = applicationDelegate.savedRecipesDict[mealType]
        
        // Typecast the AnyObject to a swift array
        var recipeInfoArray = recipeInfo! as! [[String]]
        
        // Grabs the recipe name from the double array
        cell.textLabel!.text = recipeInfoArray[row][0]
        cell.detailTextLabel!.text = "Rating: \(recipeInfoArray[row][1])/5"
        
        let imageUrl = recipeInfoArray[row][2]
        
        // This grabs the Image URL from JSON
        dispatch_async(GlobalUserInitiatedQueue)
        {
            let imageNSURL = NSURL(string: imageUrl)
            
            var imageData: NSData?
            
            do {
                /*
                 Try getting the thumbnail image data from the URL and map it into virtual memory, if possible and safe.
                 DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
                 */
                imageData = try NSData(contentsOfURL: imageNSURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch let error as NSError
            {
                self.showErrorMessage("Error in retrieving thumbnail image data: \(error.localizedDescription)")
            }
            
            dispatch_async(self.GlobalMainQueue,
                           {
                            if let image = imageData
                            {
                                // Image was successfully gotten
                                cell.imageView!.image = UIImage(data: image)
                            }
                            else
                            {
                                self.showErrorMessage("Error occurred while retrieving recipe image data!")
                            }
                            cell.setNeedsLayout()
            })
        }
        
        return cell
    }
    
    
    /*
     -------------------------------------------------------------------
     Informs the table view delegate that the specified row is selected.
     -------------------------------------------------------------------
     */
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let row: Int = indexPath.row    // Identify the row number
        let section = indexPath.section // Identify the section
        
        // Obtain type of meal - the section
        let mealType = sectionTypeArray[section]
        
        // obtain recipe names
        let recipeInfo: AnyObject? = applicationDelegate.savedRecipesDict[mealType]
        
        // Typecast the AnyObject to a swift array
        var recipeInfoArray = recipeInfo! as! [[String]]
        
        recipeName = recipeInfoArray[row][0]
        
        nutritionDataArray.removeAll()
        
        var i = 3
        while (i < 18)
        {
            nutritionDataString = recipeInfoArray[row][i]
            nutritionDataArray.append(nutritionDataString)
            i = i + 1
        }
        
        recipeImageUrl = recipeInfoArray[row][18]
        calories = Int(recipeInfoArray[row][19])!
        totalTime = recipeInfoArray[row][20]
        servings = Int(recipeInfoArray[row][21])!
        recipeUrl = recipeInfoArray[row][22]
        
        self.performSegueWithIdentifier("showMealFromSchedule", sender: self)
    }
    
    
    /*
     -------------------------
     MARK: - Prepare for segue
     -------------------------
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showMealFromSchedule"
        {
            let seeRecipeFromScheduleViewController: SeeRecipeFromScheduleViewController = segue.destinationViewController as! SeeRecipeFromScheduleViewController
            
            seeRecipeFromScheduleViewController.nutritionDataArray = self.nutritionDataArray
            seeRecipeFromScheduleViewController.servings = self.servings
            seeRecipeFromScheduleViewController.totalTime = self.totalTime
            seeRecipeFromScheduleViewController.calories = self.calories
            seeRecipeFromScheduleViewController.recipeImageUrl = self.recipeImageUrl
            seeRecipeFromScheduleViewController.recipeUrl = self.recipeUrl
            seeRecipeFromScheduleViewController.recipeName = self.recipeName
        }
    }
    
    
    /*
     --------------------------------------
     MARK: - Grand Central Dispatch Methods
     --------------------------------------
     
     These methods allow the application to download in the background by using multiple threads (including the
     main thread) to do the work.
     */
    
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    /*
     ------------------------------------------------
     MARK: - Show Alert View Displaying Error Message
     ------------------------------------------------
     */
    func showErrorMessage(errorMessage: String) {
        dispatch_async(dispatch_get_main_queue())
        { () -> Void in
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local constant alertController
             */
            let alertController = UIAlertController(title: "Unable to Obtain Data!", message: errorMessage,
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
}

