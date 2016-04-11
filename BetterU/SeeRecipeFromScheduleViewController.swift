//
//  SeeRecipeFromScheduleViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/10/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class SeeRecipeFromScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var servingsLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
    
    @IBOutlet var getRecipeButton: UIButton!
    @IBOutlet var nutritionDataTable: UITableView!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Intiailizing variables that were passed downstream in order to set information onto the view
    var recipeName = ""
    var recipeImageUrl = ""
    var totalTime = ""
    var servings = 0
    var calories = 0
    var recipeUrl = ""
    var recipeRatings = 0
    var imageSize90Url = ""
    
    // Initialize array to pass so that the tableview can populate the cells
    var nutritionTitleArray = [String]()
    var nutritionDataArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = recipeName
        getRecipeButton.layer.cornerRadius = 8
        
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
        
        // Sets the image and labels as the information that were passed down from each view
        setRecipeImageLarge(recipeImageUrl)
        caloriesLabel!.text = "Calories: \(calories)"
        totalTimeLabel!.text = "Total Time: \(totalTime)"
        servingsLabel!.text = "Servings: \(servings)"
        
        // Create a custom button with the checkmark image
        let btnName = UIButton()
        btnName.setImage(UIImage(named: "checkmark4"), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 15, 15)
        btnName.addTarget(self, action: #selector(SeeRecipeFromScheduleViewController.addCalories(_:)), forControlEvents: .TouchUpInside)
        
        // Set Right/Left Bar Button item
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCalories(sender: AnyObject)
    {
        
    }
    
    @IBAction func getRecipeButtonTapped(sender: UIButton)
    {
        self.performSegueWithIdentifier("showRecipeWeb", sender: self)
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
            imageView!.image = UIImage(data: image)
        }
        else
        {
            showErrorMessage("Error occurred while retrieving recipe image data!")
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
        cell.detailTextLabel!.text = nutritionDataArray[row]
        
        return cell
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

    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showRecipeWeb"
        {
            let recipeInstructionsWebViewController: RecipeInstructionsWebViewController = segue.destinationViewController as! RecipeInstructionsWebViewController
            
            recipeInstructionsWebViewController.recipeUrl = recipeUrl
            recipeInstructionsWebViewController.recipeTitle = recipeName
        }
    }

    
}
