//
//  RecipeInfoViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/6/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class RecipeInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Initialize storyboard objects for the view
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var numberOfServingsLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
    @IBOutlet var getRecipeButton: UIButton!
    @IBOutlet var nutritionFactsTable: UITableView!
    
    // Intiailizing variables that were passed downstream in order to set information onto the view
    var recipeName = ""
    var recipeImageUrl = ""
    var totalTime = ""
    var servings = 0
    var calories = 0
    var recipeUrl = ""
    var recipeRatings = 0
    var imageSize90Url = ""
    
    // Initializing nutritional facts. These values are passed down from the RecipeViewController class
    var totalFatWithUnit = ""
    var saturatedFatWithUnit = ""
    var monounsaturatedFatWithUnit = ""
    var polyunsaturatedFatWithUnit = ""
    var cholesterolWithUnit = ""
    var sodiumWithUnit = ""
    var potassiumWithUnit = ""
    var carbsWithUnit = ""
    var fiberWithUnit = ""
    var sugarWithUnit = ""
    var proteinWithUnit = ""
    
    // Percentage based on a 2,000 calorie diet
    var dailyVitA = ""
    var dailyVitC = ""
    var dailyCalcium = ""
    var dailyIron = ""
    
    // Passed from downstream CustomAlertViewController to then pass back downstream to the DetailTableViewController
    var selection = ""
    var selectionTypeArray = [String]()
    var recipeInfoArray = [String]()
    
    // Initialize array to pass so that the tableview can populate the cells
    var nutritionTitleArray = [String]()
    var nutritonDataArray = [String]()
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = recipeName
        getRecipeButton.layer.cornerRadius = 8
        
        // Set up the Add button on the right of the navigation bar to call the addRecipe method when tapped
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(RecipeInfoViewController.addRecipe(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        // Sets the image and labels as the information that were passed down from each view
        setRecipeImageLarge(recipeImageUrl)
        caloriesLabel!.text = "Calories: \(calories)"
        totalTimeLabel!.text = "Total Time: \(totalTime)"
        numberOfServingsLabel!.text = "Servings: \(servings)"
        
        // Nutritional title and data
        nutritionTitleArray.append("Fat")
        nutritionTitleArray.append("Saturated Fat")
        nutritionTitleArray.append("Polyunsaturated Fat")
        nutritionTitleArray.append("Monounsaturated Fat")
        nutritionTitleArray.append("Cholesterol")
        nutritionTitleArray.append("Sodium")
        nutritionTitleArray.append("Potassium")
        nutritionTitleArray.append("Carbohydrate")
        nutritionTitleArray.append("Fiber")
        nutritionTitleArray.append("Sugar")
        nutritionTitleArray.append("Protein")
        nutritionTitleArray.append("Daily Vitamin A")
        nutritionTitleArray.append("Daily Vitamin C")
        nutritionTitleArray.append("Daily Calcium")
        nutritionTitleArray.append("Daily Iron")
        
        nutritonDataArray.append(totalFatWithUnit)
        nutritonDataArray.append(saturatedFatWithUnit)
        nutritonDataArray.append(monounsaturatedFatWithUnit)
        nutritonDataArray.append(polyunsaturatedFatWithUnit)
        nutritonDataArray.append(cholesterolWithUnit)
        nutritonDataArray.append(sodiumWithUnit)
        nutritonDataArray.append(potassiumWithUnit)
        nutritonDataArray.append(carbsWithUnit)
        nutritonDataArray.append(fiberWithUnit)
        nutritonDataArray.append(sugarWithUnit)
        nutritonDataArray.append(proteinWithUnit)
        nutritonDataArray.append(dailyVitA)
        nutritonDataArray.append(dailyVitC)
        nutritonDataArray.append(dailyCalcium)
        nutritonDataArray.append(dailyIron)
        
        selectionTypeArray = applicationDelegate.savedRecipesDict.allKeys as! [String]
        selectionTypeArray.sortInPlace(){$0 < $1}
        
        recipeInfoArray.append(recipeName)
        recipeInfoArray.append(String(recipeRatings))
        recipeInfoArray.append(imageSize90Url)
        recipeInfoArray += nutritonDataArray
        recipeInfoArray.append(recipeImageUrl)
        recipeInfoArray.append(String(calories))
        recipeInfoArray.append(totalTime)
        recipeInfoArray.append(String(servings))
        recipeInfoArray.append(recipeUrl)
    }
    
    /*
     --------------------------------
     MARK: - Add Recipe Button Tapped
     --------------------------------
     */
    
    func addRecipe(sender: AnyObject)
    {
        
        openCustomAlertView()
    }
    

    /*
     ------------------------------
     MARK: - Show Custom Alert View
     ------------------------------
     */
    
    // Instantiate and present the custom alert view (popup)
    func openCustomAlertView() {
        
        let alert = storyboard?.instantiateViewControllerWithIdentifier("alert") as! CustomAlertViewController
        alert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        alert.sender2 = self
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /*
     -------------------------
     MARK: - Custom Navigation
     -------------------------
     */
    
    // Called downstream to handle custom alert view's selection
    func popToScheduleViewController()
    {
        //print(recipeInfoArray)
        // If the section exists inside of the dictionary
        if selectionTypeArray.contains(selection)
        {
            // obtain the list of recipes in the given section as AnyObject
            let recipes: AnyObject? = applicationDelegate.savedRecipesDict[selection]
            
            // Typecast the AnyObject to a Swift array of array
            var recipesFromSectionSelected = recipes! as! [[String]]
            
            // Add new recipe at the end of the list
            recipesFromSectionSelected.append(recipeInfoArray)
            
            // Update the new list of recipe
            applicationDelegate.savedRecipesDict.setValue(recipesFromSectionSelected, forKey: selection)
            
        
        }
        
        //applicationDelegate.savedRecipesDict.setValue(recipeName, forKey: selectionArray)
        //print(applicationDelegate.savedRecipesDict)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //-----------------
    // Set Recipe Image
    //-----------------
    
    func setRecipeImageLarge(imageURL: String)
    {
        // Create an NSURL from the given URL
        let url = NSURL(string: imageURL)
        
        var imageData: NSData?
        
        do {
            /*
             Try getting the thumbnail image data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            imageData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError
        {
            showErrorMessage("Error in retrieving thumbnail image data: \(error.localizedDescription)")
        }
        
        if let image = imageData
        {
            // Image was successfully gotten
            recipeImage!.image = UIImage(data: image)
        }
        else
        {
            showErrorMessage("Error occurred while retrieving recipe image data!")
        }
        
    }
    
    /*
     ---------------------------------------------
     MARK: - Get Recipe Instructions Button Tapped
     ---------------------------------------------
     */
    
    @IBAction func getRecipeButtonTapped(sender: UIButton)
    {
        self.performSegueWithIdentifier("showWebView", sender: self)
    }
    
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showWebView"
        {
            let recipeInstructionsWebViewController: RecipeInstructionsWebViewController = segue.destinationViewController as! RecipeInstructionsWebViewController
            
            recipeInstructionsWebViewController.recipeUrl = recipeUrl
            recipeInstructionsWebViewController.recipeTitle = recipeName
        }
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
    
    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    
    // Each table view section corresponds to a country
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    //---------------------------------
    // Return Number of Rows in Section
    //---------------------------------
    
    // Number of rows in a given country (section) = Number of Cities in the given country (section)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nutritionTitleArray.count
    }
    
    //-----------------------------
    // Set Title for Section Header
    //-----------------------------
    
    // Set the table view section header
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Nutritional Facts"
    }

    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("factsCells")! as UITableViewCell
        
        let row = indexPath.row
        
        cell.textLabel!.text = nutritionTitleArray[row]
        cell.detailTextLabel!.text = nutritonDataArray[row]
        
        return cell
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
