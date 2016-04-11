//
//  MealPlanViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class MealPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var logCaloriesButton: UIButton!
    @IBOutlet var recommendFoodButton: UIButton!
    @IBOutlet var mealScheduleTableView: UITableView!
    
    var selectionTypeArray = [String]()
    var nutritionDataArray = [String]()
    
    var recipeName = ""
    var recipeImageUrl = ""
    var servings = 0
    var totalTime = ""
    var calories = 0
    var recipeUrl = ""
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding in rounded corners to the buttons
        logCaloriesButton.layer.cornerRadius = 8;
        recommendFoodButton.layer.cornerRadius = 8;
        
        //selectionTypeArray = applicationDelegate.savedRecipesDict.allKeys as! [String]
        selectionTypeArray.append("Breakfast")
        selectionTypeArray.append("Lunch")
        selectionTypeArray.append("Dinner")
        selectionTypeArray.append("Snacks")
        
        // Sort the selection names within itself in alphabetical order
        selectionTypeArray.sortInPlace { $0 < $1 }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    // View will get updated with the correct recipe in the table
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        mealScheduleTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-------------------------------
    // Allow Editing of Rows
    //-------------------------------
    
    // We allow each row of the table view to be editable, i.e., deletable or movable
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func editTable() {
        
        mealScheduleTableView.setEditing(true, animated: true)
        
    }

    
    
    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    
    // Each table view section corresponds to a country
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return selectionTypeArray.count
    }
    
    //---------------------------------
    // Return Number of Rows in Section
    //---------------------------------
    
    // Number of rows in a given meal
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Obtain name of selection
        let selectionName = selectionTypeArray[section]
        
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
        
        return selectionTypeArray[section]
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
        let mealType = selectionTypeArray[section]
        
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
        let mealType = selectionTypeArray[section]
        
        // obtain recipe names
        let recipeInfo: AnyObject? = applicationDelegate.savedRecipesDict[mealType]
        
        // Typecast the AnyObject to a swift array
        var recipeInfoArray = recipeInfo! as! [[String]]
        
        recipeName = recipeInfoArray[row][0]
        
        if let nutritionDataArrayValue = applicationDelegate.savedRecipesDict["\(recipeName) Nutrition Data"] as? [String]
        {
            nutritionDataArray = nutritionDataArrayValue
        }
        
        if let recipeImageUrlValue = applicationDelegate.savedRecipesDict["\(recipeName) Img Url"] as? String
        {
            recipeImageUrl = recipeImageUrlValue
        }
        
        if let caloriesValue = applicationDelegate.savedRecipesDict["\(recipeName) Calories"] as? Int
        {
            calories = caloriesValue
        }
        
        if let totalTimeValue = applicationDelegate.savedRecipesDict["\(recipeName) Total Time"] as? String
        {
            totalTime = totalTimeValue
        }
        
        if let servingsValue = applicationDelegate.savedRecipesDict["\(recipeName) Servings"] as? Int
        {
            servings = servingsValue
        }
        
        if let recipeUrlValue = applicationDelegate.savedRecipesDict["\(recipeName) Url"] as? String
        {
            recipeUrl = recipeUrlValue
        }
        
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


