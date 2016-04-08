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
    var recipeUrlArray = [String]()
    
    let tableViewRowHeight: CGFloat = 85.0
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var recipeNameToPass = ""
    var recipeImageUrlToPass = ""
    var caloriesToPass = 0
    var totalTimeToPass = ""
    var numberOfServingsToPass = 0
    var recipeUrlToPass = ""
    var recipeRatingToPass = 0
    var imageSize90UrlToPass = ""
    
    // Initialize nutritional data variables to pass downstream onto the next view
    var totalFatWithUnitToPass = ""
    var totalSaturatedFatWithUnitToPass = ""
    var totalPolyunsaturatedFatWithUnitToPass = ""
    var totalMonounsaturatedFatWithUnitToPass = ""
    var totalCholesterolWithUnitToPass = ""
    var totalsodiumWithUnitToPass = ""
    var totalpotassiumWithUnitToPass = ""
    var totalcarbsWithUnitToPass = ""
    var totalfiberWithUnitToPass = ""
    var totalsugarWithUnitToPass = ""
    var totalproteinWithUnitToPass = ""
    var totalVitADailyPercentage = ""
    var totalVitCDailyPercentage = ""
    var totalCalciumDailyPercentage = ""
    var totalIronDailyPercentage = ""
    
    var totalFatWithUnitArray = [String]()
    var saturatedFatUnitArray = [String]()
    var polyunsaturatedFatArray = [String]()
    var monounsaturatedFatWithUnitArray = [String]()
    var cholesterolWithUnitArray = [String]()
    var sodiumWithUnitArray = [String]()
    var potassiumWithUnitArray = [String]()
    var carbsWithUnitArray = [String]()
    var fiberWithUnitArray = [String]()
    var sugarWithUnitArray = [String]()
    var proteinWithUnitArray = [String]()
    var vitaminADailyPercentArray = [String]()
    var vitaminCDailyPercentArray = [String]()
    var calciumDailyPercentArray = [String]()
    var ironDailyPercentArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearchResultsController()
        
        // Just to make sure it doesn't crash when the user did not find anything in the data
        if (applicationDelegate.recipesDict.count > 0)
        {
            recipeNameArray = applicationDelegate.recipesDict["Recipe Name"] as! [String]
            recipeRatingsArray = applicationDelegate.recipesDict["Rating"] as! [Int]
            imageSize90Array = self.applicationDelegate.recipesDict["Image"] as! [String]
            largeImageArray = applicationDelegate.recipesDict["Large Image"] as! [String]
            caloriesArray = applicationDelegate.recipesDict["Calories"] as! [Int]
            totalTimeArray = applicationDelegate.recipesDict["Total Time"] as! [String]
            numberOfServingsArray = applicationDelegate.recipesDict["Serving Size"] as! [Int]
            nutritionalFacts = applicationDelegate.recipesDict["Nutrition Facts"] as! NSDictionary
            recipeUrlArray = applicationDelegate.recipesDict["Source Url"] as! [String]
        }
        
        totalFatWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        saturatedFatUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        polyunsaturatedFatArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        monounsaturatedFatWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        cholesterolWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        sodiumWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        potassiumWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        carbsWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        fiberWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        sugarWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        proteinWithUnitArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        vitaminADailyPercentArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        vitaminCDailyPercentArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        calciumDailyPercentArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        ironDailyPercentArray = [String](count: nutritionalFacts.count, repeatedValue: "No Data")
        
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
        var calcium = 0.0
        var vitaminA = 0.0
        var vitaminC = 0.0
        var iron = 0.0
        
        while (i < nutritionalDictionary.count)
        {
            
            nutritionalFactsFromRecipeNameArray = (nutritionalDictionary[recipeNameArray[i]] as! NSArray)
            
            j = 0
            while (j < nutritionalFactsFromRecipeNameArray.count)
            {
                attributeDictionary = nutritionalFactsFromRecipeNameArray[j] as! NSDictionary
                
                attributeNameFromDict = attributeDictionary["attribute"] as! String
                
                // Potassium
                if attributeNameFromDict == "K"
                {
                    potassium = attributeDictionary["value"] as! Double
                    potassiumWithUnitArray[i] = String(Int(potassium)) + "mg"
                }
                
                // Total Fat
                else if attributeNameFromDict == "FAT"
                {
                    fat = attributeDictionary["value"] as! Double
                    totalFatWithUnitArray[i] = String(Int(fat)) + "g"
                }
                
                // Total saturated Fat
                else if attributeNameFromDict == "FASAT"
                {
                    saturatedFat = attributeDictionary["value"] as! Double
                    saturatedFatUnitArray[i] = String(Int(saturatedFat)) + "g"
                }
                
                // polyunsaturated fat
                else if attributeNameFromDict == "FAPU"
                {
                    polyunsaturatedFat = attributeDictionary["value"] as! Double
                    polyunsaturatedFatArray[i] = String(Int(polyunsaturatedFat)) + "g"
                }
                
                // monounsaturated Fat
                else if attributeNameFromDict == "FAMS"
                {
                    monounsaturatedFat = attributeDictionary["value"] as! Double
                    monounsaturatedFatWithUnitArray[i] = String(Int(monounsaturatedFat)) + "g"
                }
                
                // Cholesterol
                else if attributeNameFromDict == "CHOLE"
                {
                    cholesterol = attributeDictionary["value"] as! Double
                    cholesterolWithUnitArray[i] = String(Int(cholesterol)) + "mg"
                }
                
                // Sodium
                else if attributeNameFromDict == "NA"
                {
                    sodium = attributeDictionary["value"] as! Double
                    sodiumWithUnitArray[i] = String(Int(sodium)) + "mg"
                }

                // Carbohydrate
                else if attributeNameFromDict == "CHOCDF"
                {
                    carbs = attributeDictionary["value"] as! Double
                    carbsWithUnitArray[i] = String(Int(carbs)) + "g"
                }
                
                // Fiber
                else if attributeNameFromDict == "FIBTG"
                {
                    fiber = attributeDictionary["value"] as! Double
                    fiberWithUnitArray[i] = String(Int(fiber)) + "g"
                }
                
                // Sugar
                else if attributeNameFromDict == "SUGAR"
                {
                    sugar = attributeDictionary["value"] as! Double
                    sugarWithUnitArray[i] = String(Int(sugar)) + "g"
                }
                
                // Protein
                else if attributeNameFromDict == "PROCNT"
                {
                    protein = attributeDictionary["value"] as! Double
                    proteinWithUnitArray[i] = String(Int(protein)) + "g"
                }
                
                // Vitamin A
                else if attributeNameFromDict == "VITA_IU"
                {
                    vitaminA = attributeDictionary["value"] as! Double
                    let vitaminADailyPercentage = (vitaminA/5000) * 100
                    vitaminADailyPercentArray[i] = String(Int(vitaminADailyPercentage)) + "%"
                }
                
                // Vitamin C
                else if attributeNameFromDict == "VITC"
                {
                    vitaminC = attributeDictionary["value"] as! Double
                    let vitaminCInMilligrams = vitaminC * 1000
                    let vitaminCDailyPercentage = (vitaminCInMilligrams/60) * 100
                    vitaminCDailyPercentArray[i] = String(Int(vitaminCDailyPercentage)) + "%"
                }
                
                // Calcium
                else if attributeNameFromDict == "CA"
                {
                    calcium = attributeDictionary["value"] as! Double
                    let calciumInMilligrams = calcium * 1000
                    let calciumDailyPercentage = (calciumInMilligrams/1000) * 100
                    calciumDailyPercentArray[i] = String(Int(calciumDailyPercentage)) + "%"
                }
                
                // Iron
                else if attributeNameFromDict == "FE"
                {
                    iron = attributeDictionary["value"] as! Double
                    let ironInMilligrams = iron * 1000
                    let ironDailyPercentage = (ironInMilligrams/1000) * 100
                    ironDailyPercentArray[i] = String(Int(ironDailyPercentage)) + "%"
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
        recipeUrlToPass = recipeUrlArray[row]
        recipeRatingToPass = recipeRatingsArray[row]
        imageSize90UrlToPass = imageSize90Array[row]
        
        totalFatWithUnitToPass = totalFatWithUnitArray[row]
        totalSaturatedFatWithUnitToPass = saturatedFatUnitArray[row]
        totalPolyunsaturatedFatWithUnitToPass = polyunsaturatedFatArray[row]
        totalMonounsaturatedFatWithUnitToPass = monounsaturatedFatWithUnitArray[row]
        totalCholesterolWithUnitToPass = cholesterolWithUnitArray[row]
        totalsodiumWithUnitToPass = sodiumWithUnitArray[row]
        totalpotassiumWithUnitToPass = potassiumWithUnitArray[row]
        totalcarbsWithUnitToPass = carbsWithUnitArray[row]
        totalfiberWithUnitToPass = fiberWithUnitArray[row]
        totalsugarWithUnitToPass = sugarWithUnitArray[row]
        totalproteinWithUnitToPass = proteinWithUnitArray[row]
        totalVitADailyPercentage = vitaminADailyPercentArray[row]
        totalVitCDailyPercentage = vitaminCDailyPercentArray[row]
        totalCalciumDailyPercentage = calciumDailyPercentArray[row]
        totalIronDailyPercentage = ironDailyPercentArray[row]
        
        
        self.performSegueWithIdentifier("recipeInfoView", sender: self)
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
            recipeInfoViewController.cholesterolWithUnit = totalCholesterolWithUnitToPass
            recipeInfoViewController.sodiumWithUnit = totalsodiumWithUnitToPass
            recipeInfoViewController.potassiumWithUnit = totalpotassiumWithUnitToPass
            recipeInfoViewController.carbsWithUnit = totalcarbsWithUnitToPass
            recipeInfoViewController.fiberWithUnit = totalfiberWithUnitToPass
            recipeInfoViewController.sugarWithUnit = totalsugarWithUnitToPass
            recipeInfoViewController.proteinWithUnit = totalproteinWithUnitToPass
            recipeInfoViewController.dailyVitA = totalVitADailyPercentage
            recipeInfoViewController.dailyVitC = totalVitCDailyPercentage
            recipeInfoViewController.dailyCalcium = totalCalciumDailyPercentage
            recipeInfoViewController.dailyIron = totalIronDailyPercentage
            recipeInfoViewController.recipeUrl = recipeUrlToPass
            recipeInfoViewController.recipeRatings = recipeRatingToPass
            recipeInfoViewController.imageSize90Url = imageSize90UrlToPass
            
        }
    }
}
