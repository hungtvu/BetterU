//
//  RecipeViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {

    var barcodeButton: UIButton = UIButton()
    
    @IBOutlet var recipeTableView: UITableView!
    
    // These two instance variables are used for Search Bar functionality
    var searchResults = [String]()
    var searchResultsController = UISearchController()
    
    var recipeNameArray = [String]()
    var recipeRatingsArray = [Int]()
    var imageSize90Array = [String]()
    var largeImageArray = [String]()
    var caloriesArray = [Int]()
    var totalTimeArray = [String]()
    var numberOfServingsArray = [Int]()
    var nutritionalFacts = NSDictionary()
    
    let tableViewRowHeight: CGFloat = 85.0
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var recipeNameToPass = ""
    var recipeImageUrlToPass = ""
    var caloriesToPass = 0
    var totalTimeToPass = ""
    var numberOfServingsToPass = 0
    var totalFatWithUnitToPass = ""
    var totalSaturatedFatWithUnitToPass = ""
    var totalPolyunsaturatedFatWithUnitToPass = ""
    var totalMonounsaturatedFatWithUnitToPass = ""
    
    var totalFatWithUnitArray = [String]()
    var saturatedFatUnitArray = [String]()
    var polyunsaturatedFatArray = [String]()
    var monounsaturatedFatWithUnitArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearchResultsController()
        
        // Just to make sure it doesn't crash when the user did not find anything in the data
        if (applicationDelegate.recipesDict.count > 0)
        {
            recipeNameArray = applicationDelegate.recipesDict["Recipe Name"] as! [String]
            recipeRatingsArray = applicationDelegate.recipesDict["Rating"] as! [Int]
            largeImageArray = applicationDelegate.recipesDict["Large Image"] as! [String]
            caloriesArray = applicationDelegate.recipesDict["Calories"] as! [Int]
            totalTimeArray = applicationDelegate.recipesDict["Total Time"] as! [String]
            numberOfServingsArray = applicationDelegate.recipesDict["Serving Size"] as! [Int]
            nutritionalFacts = applicationDelegate.recipesDict["Nutrition Facts"] as! NSDictionary
        }
        
        totalFatWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        saturatedFatUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        polyunsaturatedFatArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        monounsaturatedFatWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        
        grabNutritionalFacts(nutritionalFacts)
        
        // Create a custom back button on the navigation bar
        // This will let us pop the current view controller to the one before the previous view
        // This is needed so that the user does not have to see the previous loading screen
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
        myBackButton.addTarget(self, action: #selector(RecipeViewController.popBackTwoViews(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("< Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem = myCustomBackButtonItem
      
    }
    
    func grabNutritionalFacts(nutritionalDictionary: NSDictionary)
    {
        var i = 0
        var j = 0
        
        var nutritionalFactsFromRecipeNameArray = NSArray()
        var attributeDictionary = NSDictionary()
        
        var attributeNameFromDict = ""
        
        var fat = 0.0
        var saturatedFat = 0.0
        var polyunsaturatedFat = 0.0
        var monounsaturatedFat = 0.0
        var cholesterol = 0.0
        var sodium = 0.0
        var potassium = 0.0
        var carbs = 0.0
        var fiber = 0.0
        var sugar = 0.0
        var protein = 0.0
        
        
        while (i < nutritionalDictionary.count)
        {
            nutritionalFactsFromRecipeNameArray = (nutritionalDictionary[recipeNameArray[i]] as! NSArray)
            
            while (j < nutritionalFactsFromRecipeNameArray.count)
            {
                attributeDictionary = nutritionalFactsFromRecipeNameArray[j] as! NSDictionary
                
                attributeNameFromDict = attributeDictionary["attribute"] as! String
                
                // Total Fat
                if attributeNameFromDict == "FAT"
                {
                    fat = attributeDictionary["value"] as! Double
                    totalFatWithUnitArray[i] = String(fat) + "g"
                }
                
                // Total saturated Fat
                if attributeNameFromDict == "FASAT"
                {
                    //totalSaturatedFatArray.append(attributeDictionary["value"] as! Double)
                    saturatedFat = attributeDictionary["value"] as! Double
                    saturatedFatUnitArray[i] = String(saturatedFat) + "g"
                }
                
                // polyunsaturated fat
                if attributeNameFromDict == "FAPU"
                {
                    polyunsaturatedFat = attributeDictionary["value"] as! Double
                    polyunsaturatedFatArray[i] = String(polyunsaturatedFat) + "g"
                }
                
                // monounsaturated Fat
                if attributeNameFromDict == "FAMS"
                {
                    monounsaturatedFat = attributeDictionary["value"] as! Double
                    monounsaturatedFatWithUnitArray[i] = String(monounsaturatedFat) + "g"
                }
                
                // Cholesterol
                if attributeNameFromDict == "CHOLE"
                {
                    cholesterol = attributeDictionary["value"] as! Double
                }
                
                // Sodium
                if attributeNameFromDict == "NA"
                {
                    sodium = attributeDictionary["value"] as! Double
                }
                
                // Potassium
                if attributeNameFromDict == "K"
                {
                    potassium = attributeDictionary["value"] as! Double
                }
                
                // Carbohydrate
                if attributeNameFromDict == "CHOCDF"
                {
                    carbs = attributeDictionary["value"] as! Double
                }
                
                // Fiber
                if attributeNameFromDict == "FIBTG"
                {
                    fiber = attributeDictionary["value"] as! Double
                }
                
                // Sugar
                if attributeNameFromDict == "SUGAR"
                {
                    sugar = attributeDictionary["value"] as! Double
                }
                
                j = j + 1
            }
            
            i = i + 1
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.recipeTableView.reloadData()
        })
    }
    
    // Calls the nagivation controller and sets the RecommendMealViewController view to go back to
    // Calls the popToViewController() method to pop the current view and segues into the previous view
    func popBackTwoViews(sender: UIBarButtonItem)
    {
        //let recommendMealViewController = self.navigationController?.viewControllers[1] as! RecommendMealViewController
        //self.navigationController?.popToViewController(recommendMealViewController, animated: true)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func barcodeButtonTapped(sender: UIButton)
    {
        
    }
    
    /*
     ---------------------------------------------
     MARK: - Creation of Search Results Controller
     ---------------------------------------------
     */
    func createSearchResultsController() {
        /*
         Instantiate a UISearchController object and store its object reference into local variable: controller.
         Setting the parameter searchResultsController to nil implies that the search results will be displayed
         in the same view used for searching (under the same UITableViewController object).
         */
        let controller = UISearchController(searchResultsController: nil)
        
        /*
         We use the same table view controller (self) to also display the search results. Therefore,
         set self to be the object responsible for listing and updating the search results.
         Note that we made self to conform to UISearchResultsUpdating protocol.
         */
        controller.searchResultsUpdater = self
        
        /*
         The property dimsBackgroundDuringPresentation determines if the underlying content is dimmed during
         presentation. We set this property to false since we are presenting the search results in the same
         view that is used for searching. The "false" option displays the search results without dimming.
         */
        controller.dimsBackgroundDuringPresentation = false
        
        // Resize the search bar object based on screen size and device orientation.
        controller.searchBar.sizeToFit()
        
        /***************************************************************************
         No need to create the search bar in the Interface Builder (storyboard file).
         The statement below creates it at runtime.
         ***************************************************************************/
        
        // Set the tableHeaderView's accessory view displayed above the table view to display the search bar.
        self.recipeTableView.tableHeaderView = controller.searchBar
        
        /*
         Set self (Table View Controller) define the presentation context so that the Search Bar subview
         does not show up on top of the view (scene) displayed by a downstream view controller.
         */
        self.definesPresentationContext = true
        
        /*
         Set the object reference (controller) of the newly created and dressed up UISearchController
         object to be the value of the instance variable searchResultsController.
         */
        searchResultsController = controller
    }
    
    /*
     -----------------------------------------------
     MARK: - UISearchResultsUpdating Protocol Method
     -----------------------------------------------
     
     This UISearchResultsUpdating protocol required method is automatically called whenever the search
     bar becomes the first responder or changes are made to the text or scope of the search bar.
     You must perform all required filtering and updating operations inside this method.
     */
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // Empty the instance variable searchResults array without keeping its capacity
        searchResults.removeAll(keepCapacity: false)
        
        // Set searchPredicate to search for any character(s) the user enters into the search bar.
        // [c] indicates that the search is case insensitive.
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        // Obtain the country names that contain the character(s) the user types into the Search Bar.
        //let listOfCountryNamesFound = (countryNames as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        // Obtain the search results as an array of type String
       // searchResults = listOfCountryNamesFound as! [String]
        
        // Reload the table view to display the search results
        self.recipeTableView.reloadData()
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
        
        return recipeNameArray.count
    }
    
    // Asks the table view delegate to return the height of a given row.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return tableViewRowHeight
    }
    
    /*
     ---------------------------------
     MARK: - TableViewDelegate Methods
     ---------------------------------
     */
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row: Int = indexPath.row
        
        // In the Interface Builder (storyboard file), set the table view cell's identifier attribute to "CountryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = recipeNameArray[row]
        cell.detailTextLabel!.text = "Rating: \(recipeRatingsArray[row])/5"
        
        imageSize90Array = self.applicationDelegate.recipesDict["Image"] as! [String]
        
        // This grabs the Image URL from JSON
        dispatch_async(GlobalUserInitiatedQueue)
        {

        // Create an NSURL from the given URL
        let url = NSURL(string: self.imageSize90Array[row])
        
        var imageData: NSData?
        
        do {
            /*
             Try getting the thumbnail image data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            imageData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
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
        
        recipeNameToPass = recipeNameArray[row]
        recipeImageUrlToPass = largeImageArray[row]
        caloriesToPass = caloriesArray[row]
        totalTimeToPass = totalTimeArray[row]
        numberOfServingsToPass = numberOfServingsArray[row]
        
        totalFatWithUnitToPass = totalFatWithUnitArray[row]
        totalSaturatedFatWithUnitToPass = saturatedFatUnitArray[row]
        totalPolyunsaturatedFatWithUnitToPass = polyunsaturatedFatArray[row]
        totalMonounsaturatedFatWithUnitToPass = monounsaturatedFatWithUnitArray[row]
        
        self.performSegueWithIdentifier("recipeInfoView", sender: self)
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "recipeInfoView"
        {
            let recipeInfoViewController: RecipeInfoViewController = segue.destinationViewController as! RecipeInfoViewController
            
            recipeInfoViewController.recipeName = recipeNameToPass
            recipeInfoViewController.recipeImageUrl = recipeImageUrlToPass
            recipeInfoViewController.calories = caloriesToPass
            recipeInfoViewController.totalTime = totalTimeToPass
            recipeInfoViewController.servings = numberOfServingsToPass
            recipeInfoViewController.totalFatWithUnit = totalFatWithUnitToPass
            recipeInfoViewController.saturatedFatWithUnit = totalSaturatedFatWithUnitToPass
            recipeInfoViewController.polyunsaturatedFatWithUnit = totalPolyunsaturatedFatWithUnitToPass
            recipeInfoViewController.monounsaturatedFatWithUnit = totalMonounsaturatedFatWithUnitToPass
            
        }
    }
}
