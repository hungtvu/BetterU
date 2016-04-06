//
//  RecommendMealViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class RecommendMealViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var preferenceTextField: UITextField!
    
    @IBOutlet var levelOfCaloriesTableView: UITableView!
    // Not used here, just for reference
    let usdaAPIKey = "lmng23Wvez10CHDEqiWE90dL1qWhJrkXlqIIXRmN"
    
    var recipeCount: Int = 0
    var recipesInDatabase = [String]()
    var matchedRecipes = [AnyObject]()
    var recipeID = [String]()
    // Initialize keys needed to obtain yummly API data
    let yummylyAppID = "648e9030"
    let yummlyAPIKey = "0e7f65d6979544b4683291e72232e1c1"
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var recipeNameArray = [String]()
    var recipeRatingsArray = [Int]()
    var imageSize90Array = [String]()
    
    var caloriesFromRecipes = [Int]()
    var recipeName_dict_calories = [String: Int]()
    var recipeName_dict_images = [String: String]()
    var recipeName_dict_rating = [String: Int]()
    
    // Initializing the dictionaries for the difficulties of each recipe based on caloric intake
    var recipeName_dict_max250Cal = [String: Int]()
    var recipeName_dict_max500Cal = [String: Int]()
    var recipeName_dict_max750Cal = [String: Int]()
    var recipeName_dict_max1000Cal = [String: Int]()
    
    var hasDataBeenFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialJsonParse()
    {
        let excludedFood = preferenceTextField!.text
        
        // Separates all characters and string and add it into an array
        let excludedFoodArrayWithComma = excludedFood?.characters.split {$0 == "," || $0 == " "}.map(String.init)
        
        var exclusionString = ""
        
        // Creates a string that allows excluded items
        var i = 0
        while (i < excludedFoodArrayWithComma?.count)
        {
            exclusionString += "&excludedIngredient[]=\(excludedFoodArrayWithComma![i])"
            i += 1
        }
        
        var dictionaryOfRecipes = [String: AnyObject]()
        
        // Instantiate an API URL to return the JSON data
        let apiURL = "http://api.yummly.com/v1/api/recipes?_app_id=\(yummylyAppID)&_app_key=\(yummlyAPIKey)&requirePictures=true&maxResult=10&start=10\(exclusionString)"
        
        // Convert URL to NSURL
        let url = NSURL(string: apiURL)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError
        {
            self.showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
            return
        }
        
        if let jsonDataFromApiURL = jsonData
        {
            // The JSON data is successfully obtained from the API
            
            /*
             NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
             NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
             */
            
            do
            {
                let jsonDataDictionary = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                dictionaryOfRecipes = jsonDataDictionary as! Dictionary<String, AnyObject>
                
                // Grabs all of the matched recipes
                // This will return an array of all of the matched recipes
                self.matchedRecipes = dictionaryOfRecipes["matches"] as! Array<AnyObject>
                
                // Returns the first 10 recipes shown in the JSON data
                self.recipeCount = self.matchedRecipes.count
                
                // Obtain the Dictionary containing the data about the selected movie to pass to the downstream view controller
                var j = 0
                var recipesDict = Dictionary<String, AnyObject>()
                var recipeName = ""
                var recipeRatings = 0
                var imageURL = NSDictionary()
                var imageSize90 = ""
                
                while (j < recipeCount)
                {
                    recipesDict = matchedRecipes[j] as! Dictionary<String, AnyObject>
                    recipeID.append(recipesDict["id"] as! String)
                    recipeName = recipesDict["recipeName"] as! String
                    recipeRatings = recipesDict["rating"] as! Int
                    
                    imageURL = recipesDict["imageUrlsBySize"] as! NSDictionary
                    imageSize90 = imageURL["90"] as! String
                    
                    recipeName_dict_images[recipeName] = imageSize90
                    recipeName_dict_rating[recipeName] = recipeRatings
                    
                    recipeNameArray.append(recipeName)
                    
                    
                    j = j + 1
                }
                
                
                
               
            }catch let error as NSError
            {
                self.showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
        }
            
        else
        {
            self.showErrorMessage("Error in retrieving JSON data!")
        }
    }
    
    func parseRecipeJson()
    {
        var recipeDictFromID = [String: AnyObject]()
        var apiURL = ""
        var url = NSURL()
        var jsonData = NSData?()
        
        var i = 0
        while (i < recipeID.count) {
            // Instantiate an API URL to return the JSON data
            apiURL = "http://api.yummly.com/v1/api/recipe/\(recipeID[i])?_app_id=\(yummylyAppID)&_app_key=\(yummlyAPIKey)"
        
            // Convert URL to NSURL
            url = NSURL(string: apiURL)!
            
            do {
                /*
                 Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
                 DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
                 */
                jsonData = try NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch let error as NSError
            {
                showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
        
            if let jsonDataFromApiURL = jsonData
            {
                // The JSON data is successfully obtained from the API
                
                /*
                 NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
                 NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
                 */
            
                do
                {
                    let jsonDataDictionary = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                    // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                    recipeDictFromID = jsonDataDictionary as! Dictionary<String, AnyObject>
                    
                    //print(recipeDictFromID)
                    let nutritionFacts = recipeDictFromID["nutritionEstimates"] as! NSArray
                    caloriesFromRecipes.append(setRecipeCalories(nutritionFacts))
                    
                    let calories = setRecipeCalories(nutritionFacts)
                    recipeName_dict_calories[recipeNameArray[i]] = calories
                    
                }catch let error as NSError
                {
                    showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
                    return
                }
            }
            
            else
            {
                showErrorMessage("Error in retrieving JSON data!")
            }
        
            i = i + 1
        }
        
        var k = 0
        while (k < recipeCount)
        {
            if (caloriesFromRecipes[k] <= 250)
            {
                if let max250Cal = recipeName_dict_calories[recipeNameArray[k]]
                {
                    recipeName_dict_max250Cal[recipeNameArray[k]] = max250Cal
                }
            }
            
            else if (caloriesFromRecipes[k] <= 500 && caloriesFromRecipes[k] > 250)
            {
                if let max500Cal = recipeName_dict_calories[recipeNameArray[k]]
                {
                    recipeName_dict_max500Cal[recipeNameArray[k]] = max500Cal
                }
            }
            
            else if (caloriesFromRecipes[k] <= 750 && caloriesFromRecipes[k] > 500)
            {
                if let max750Cal = recipeName_dict_calories[recipeNameArray[k]]
                {
                    recipeName_dict_max750Cal[recipeNameArray[k]] = max750Cal
                }
            }
            
            else
            {
                if let max1000Cal = recipeName_dict_calories[recipeNameArray[k]]
                {
                    recipeName_dict_max1000Cal[recipeNameArray[k]] = max1000Cal
                }
            }
            
            k = k + 1
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let row: Int = indexPath.row
        
        // Populating the calories burned row
        if row == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("easyCell")! 
            
            // Grab the row count from the indexPath in the cell
            cell.textLabel!.text = "Easy"
            cell.detailTextLabel!.text = "Maximum 250 calorie meals"
            
            return cell
        }
        
        else if row == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("mediumCell")!
            
            // Grab the row count from the indexPath in the cell
            cell.textLabel!.text = "Medium"
            cell.detailTextLabel!.text = "Maximum 500 calorie meals"
            
            return cell
        }
        
        else if row == 2
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("hardCell")!
            
            // Grab the row count from the indexPath in the cell
            cell.textLabel!.text = "Hard"
            cell.detailTextLabel!.text = "Maximum 750 calorie meals"
            
            return cell
        }
        
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("veryHardCell")!
            
            // Grab the row count from the indexPath in the cell
            cell.textLabel!.text = "Very Hard"
            cell.detailTextLabel!.text = "Maximum 1000 calorie meals"
            
            return cell
        }
    }
    
    // MARK: - Table view data source
    
    // There is only one section in the table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // This method tells you how many rows there are in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }

    
    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */
    
    
    // Informs the table view delegate that the specified row is selected.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        hasDataBeenFetched = false
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.initialJsonParse()
            self.parseRecipeJson()
        
            // Easy mode - max of 250 calories
            if rowNumber == 0
            {
                self.createDictValuesFromDifficulties(self.recipeName_dict_max250Cal)
            }
            
            // Medium mode - max of 500 calories
            else if rowNumber == 1
            {
                self.createDictValuesFromDifficulties(self.recipeName_dict_max500Cal)
            }
            
            // Hard mode - max of 750 calories
            else if rowNumber == 2
            {
                self.createDictValuesFromDifficulties(self.recipeName_dict_max750Cal)
            }
            
            // Very hard mode - max of 1000 calories
            else
            {
                self.createDictValuesFromDifficulties(self.recipeName_dict_max1000Cal)
            }
            
        }
        hasDataBeenFetched = true
        
        performSegueWithIdentifier("activityIndicatorView", sender: self)
        
    }
    
    func createDictValuesFromDifficulties(recipeName_dict_maxCal: [String: Int])
    {
        var keyArray = [String]()
        var recipeRatingsArr = [Int]()
        var imageSize90Arr = [String]()
        
        for (key, _) in recipeName_dict_maxCal
        {
            keyArray.append(key)
            self.applicationDelegate.recipesDict.setValue(keyArray, forKey: "Recipe Name")
            
            // Grab the image URL pertaining to the recipe name
            if let imageSize90Value = self.recipeName_dict_images[key]
            {
                imageSize90Arr.append(imageSize90Value)
                self.applicationDelegate.recipesDict.setValue(imageSize90Arr, forKey: "Image")
            }
            
            // Grabs the rating from the JSON
            if let ratingValue = self.recipeName_dict_rating[key]
            {
                recipeRatingsArr.append(ratingValue)
                self.applicationDelegate.recipesDict.setValue(recipeRatingsArr, forKey: "Rating")
            }
        }
        
    }
    
    //--------------------
    // Set Recipe Calories
    //--------------------
    
    // This function calculates the total calories per serving in a formula
    func setRecipeCalories(nutritionEstimate: NSArray) -> Int
    {
        // Initializes variables as double
        var totalFat = 0.0
        var carbohydrates = 0.0
        var protein = 0.0
        
        var i = 0
        // Loops through the array and sees if there is a match
        // We do this because some recipes have different size arrays
        while (i < nutritionEstimate.count)
        {
            if let attribute = nutritionEstimate[i] as? NSDictionary
            {
                // Initialize the name from each dictionary entry
                let attributeName = attribute["attribute"] as! String
                
                // If the name matches to fat
                if attributeName == "FAT"
                {
                    // Sets total fat as that value
                    totalFat = attribute["value"] as! Double
                }
                
                // If the name matches to protein
                if attributeName == "PROCNT"
                {
                    // Sets protein as that value
                    protein = attribute["value"] as! Double
                }
                
                // If the name matches carbohydrates
                if attributeName == "CHOCDF"
                {
                    // Sets it as that value
                    carbohydrates = attribute["value"] as! Double
                }
            }
            
            i = i + 1
        }
        
        // Calculate the calories per serving from those 3 values
        let caloriesPerServing = (totalFat * 9) + (carbohydrates * 4) + (protein * 4)
        
        return Int(caloriesPerServing)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "activityIndicatorView"
        {
            let activityIndicatorViewController: ActivityIndicatorViewController = segue.destinationViewController as! ActivityIndicatorViewController
            
            activityIndicatorViewController.hasDataBeenFetched = self.hasDataBeenFetched
            
        }
    }
}
