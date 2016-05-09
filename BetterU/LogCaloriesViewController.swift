//
//  LogCaloriesViewController.swift
//  BetterU
//
//  Created by Hung Vu, Corey McQuay on 4/11/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LogCaloriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    // Initializing object references to the field objects on the view
    @IBOutlet var caloriesTextField: UITextField!
    @IBOutlet var nutritionFoodTableView: UITableView!
    @IBOutlet var barcodeButton: UIButton!
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // These are API Keys from the USDA API. Free keys are available on their website.
    let usdaApiKey = "4niv8KdOlh2eILltqqldVhCoNsw62qKN6NiRPSo4"
    let usdaApiKey2 = "kpXNL7bTB0hPpWVSWNnPePhsHg0OnTforAKvJ7NE"
    let usdaApiKey3 = "6qer4AubBAx23pY4cizKwaDznfmCNyEJ3uxZlnEJ"
    
    var foodItemName_Dict_foodItemNumber = [String: String]()
    var foodItemArray = [String]()
    var itemNumberArray = [String]()
    var filteredFoodItemArray = [String]()
    var resultsSearchController = UISearchController()
    
    var userId = 0
    
    // Initialize variables for the PUT request
    var caloriesIn = 0
    var caloriesOut = 0
    var miles = 0.0
    var steps = 0
    var weight = 0.0
    var logDate = 0
    var epochTime = 0
    
    var itemName = ""
    var itemNumber = ""
    var proteinValue = ""
    var fatValue = ""
    var carbsValue = ""
    var foodSizeMeasureArray: Array<String> = []
    var caloriesArray: Array<String> = [] 
    
    var foodDictFromFoodArray = NSDictionary()
    
    var refreshControl: UIRefreshControl!
    
    var hasDataBeenDownloaded = false
    
    // Initialize variables that are passed downstream to the FoodNutritionViewController
    var foodNameToPass = ""
    var foodServingSizeToPass = ""
    var caloriesToPass = ""
    var ndbnoToPass = ""
    
    // Create a button in the program
    var logCaloriesButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Grabs the user's ID upon entering the view
        userId = applicationDelegate.userAccountInfo["id"] as! Int

        self.resultsSearchController = UISearchController(searchResultsController: nil)
        self.resultsSearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.resultsSearchController.searchBar.delegate = self
    
        self.resultsSearchController.searchBar.sizeToFit()
        
        //resultsSearchController.searchBar.frame = CGRectMake(0, 0, 180, 20)
        self.resultsSearchController.searchBar.placeholder = "Food item search"
        //self.navigationItem.titleView = self.resultsSearchController.searchBar
        self.resultsSearchController.hidesNavigationBarDuringPresentation = false;
        self.nutritionFoodTableView.tableHeaderView = self.resultsSearchController.searchBar
        self.nutritionFoodTableView.reloadData()
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        
        logCaloriesButton = UIButton(type: UIButtonType.System) as UIButton
        logCaloriesButton.frame = CGRectMake(screenWidth * 0.35, 170, 115, 30)
        logCaloriesButton.backgroundColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
        logCaloriesButton.setTitle("Log Calories", forState: UIControlState.Normal)
        logCaloriesButton.addTarget(self, action: #selector(LogCaloriesViewController.logCaloriesButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        logCaloriesButton.layer.cornerRadius = 8
        
        self.view.addSubview(logCaloriesButton)
        
        refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, 20, 20))
        refreshControl.tintColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
        
        refreshControl.addTarget(self, action: #selector(LogCaloriesViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.nutritionFoodTableView.addSubview(self.refreshControl)
        
        refreshControl.subviews[0].frame = CGRectMake(screenWidth * 0.26, 30, 20, 20)
        
        removeLinesFromTable()
        
        let date: NSDate = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate = cal.startOfDayForDate(date)
        epochTime = Int(newDate.timeIntervalSince1970)
        parseProgressForSpecificDate(epochTime)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.nutritionFoodTableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.nutritionFoodTableView.reloadData()
        })
    }
    
    func handleRefresh(sender: UIRefreshControl)
    {
        dispatch_async(dispatch_get_main_queue(),
       {
            self.nutritionFoodTableView.reloadData()
            
            if (self.refreshControl!.refreshing)
            {
                self.refreshControl!.endRefreshing()
            }
        })
    }
    
    func parseProgressForSpecificDate(dateInEpoch: Int)
    {
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/\(dateInEpoch)"
        
        // Convert URL to NSURL
        let url = NSURL(string: restApiUrl)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError
        {
            print("Error in retrieving JSON data: \(error.localizedDescription)")
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
                // Grabs all of the JSON data info as an array. NOTE, this stores ALL of the info, it does NOT have
                // any info from inside of the JSON.
                
                /*                  */
                let jsonData = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                caloriesIn = jsonData["caloriesIn"] as! Int
                caloriesOut = jsonData["caloriesOut"] as! Int
                logDate = jsonData["logDate"] as! Int
                miles = jsonData["miles"] as! Double
                steps = jsonData["steps"] as! Int
                weight = jsonData["weight"] as! Double

            }catch let error as NSError
            {
                print("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
        }
            
        else
        {
            print("Error in retrieving JSON data!")
        }
    }
    
    @IBAction func barcodeButtonTapped(sender: UIButton)
    {
        self.performSegueWithIdentifier("showBarcodeReader", sender: self)
    }
    
    func removeLinesFromTable()
    {
        if (filteredFoodItemArray.count == 0)
        {
            // Remove extra lines from the table view
            self.nutritionFoodTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.nutritionFoodTableView.scrollEnabled = false
        }
            
        // Once there is an item in the array
        else
        {
            self.nutritionFoodTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.nutritionFoodTableView.scrollEnabled = true
        }

    }
    
    func initialUSDAParse()
    {
        //dispatch_async(GlobalUserInitiatedQueue)
          //             {
        itemNumberArray.removeAll(keepCapacity: false)
        let usdaApiUrlForFoodItems = "http://api.nal.usda.gov/ndb/search/?format=json&q=\(self.resultsSearchController.searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "%20"))&sort=r&max=70&offset=0&api_key=\(self.usdaApiKey3)"
        
        // Convert URL to NSURL
        let url = NSURL(string: usdaApiUrlForFoodItems)
        
        var jsonData: NSData?
    
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch _ as NSError
        {
            self.showErrorMessage("Your search has no results. Please try again!")
            return
        }
        
        
        //dispatch_async(dispatch_get_main_queue(),
        //{
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
                
                
                /* 
                 Optional({
                 list =     {
                 end = 55;
                 group = "";
                 item =         (
                 {
                 group = "Baby Foods";
                 name = "Babyfood, apple-banana juice";
                 ndbno = 03167;
                 offset = 0;
                 },
                 {
                 group = "Baby Foods";
                 name = "Babyfood, banana apple dessert, strained";
                 ndbno = 43550;
                 offset = 1;
                 };
                 );
                 q = banana;
                 sort = n;
                 sr = 28;
                 start = 0;
                 total = 58;
                 };
                 })
                 
                 */
                
                // Grabs the full list as a dictionary
                let listOfItems = jsonDataDictionary!["list"] as! NSDictionary
                
                // Goes into that list and grabs the item as an array
                let itemArray = listOfItems["item"] as! NSArray
                
                var itemDictionaryFromArray = NSDictionary()
                
                var i = 0
                while (i < itemArray.count)
                {
                    // Does a loop throughout the items
                    itemDictionaryFromArray = itemArray[i] as! NSDictionary
                    
                    // Grabs the food item name and its nutrition database number
                    self.itemName = itemDictionaryFromArray["name"] as! String
                    self.itemNumber = itemDictionaryFromArray["ndbno"] as! String
                    self.foodItemArray.append(self.itemName)
                    self.itemNumberArray.append(itemNumber)
                    
                    i = i + 1
                    
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
        
       // }
    }

    /* Grabs the food item's nutritional database number and parses it in order to get the required nutrients for calorie calculations */
    func parseNdbno()
    {
        
        dispatch_async(GlobalUserInitiatedQueue)
        {
            self.caloriesArray = Array(count: self.foodItemArray.count, repeatedValue: "")
            self.foodSizeMeasureArray = Array(count: self.foodItemArray.count, repeatedValue: "")
            
            var i = 0
            while (i < self.foodItemArray.count) {
            
            let usdaApiUrlForFoodStats = "http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=\(self.usdaApiKey3)&nutrients=205&nutrients=204&nutrients=203&ndbno=\(self.itemNumberArray[i])"
            
            // Convert URL to NSURL
            let url = NSURL(string: usdaApiUrlForFoodStats)
            
            var jsonData: NSData?
            
            do {
                /*
                 Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
                 DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
                 */
                jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch _ as NSError
            {
                self.showErrorMessage("Your search has no results. Please try again!")
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
                    
                    let foodReport = jsonDataDictionary!["report"] as! NSDictionary
                    let foodArray = foodReport["foods"] as! NSArray
                    
                    
                    var k = 0
                    while (k < foodArray.count)
                    {
                        self.foodDictFromFoodArray = foodArray[k] as! NSDictionary
                        k = k + 1
                    }
         
                    self.foodSizeMeasureArray[i] = (self.foodDictFromFoodArray["measure"] as! String)
                    
                    let nutrientArray = self.foodDictFromFoodArray["nutrients"] as! NSArray
                    var nutrientDictFromNutrientArray = NSDictionary()
                    //print(nutrientArray)
                    var j = 0
                    while (j < nutrientArray.count)
                    {
                        nutrientDictFromNutrientArray = nutrientArray[j] as! NSDictionary
                        
                        let nutrientName = nutrientDictFromNutrientArray["nutrient"] as! String
                        
                        if nutrientName == "Protein"
                        {
                            self.proteinValue = nutrientDictFromNutrientArray["value"] as! String
                        }
                        
                        if nutrientName == "Total lipid (fat)"
                        {
                            self.fatValue = nutrientDictFromNutrientArray["value"] as! String
                        }
                        
                        if nutrientName == "Carbohydrate, by difference"
                        {
                            self.carbsValue = nutrientDictFromNutrientArray["value"] as! String
                        }
                    
                        j = j + 1
                    }
                    
                    if self.fatValue ==  "--"
                    {
                       self.fatValue = "0.0"
                    }
                    
                    else if self.proteinValue == "--"
                    {
                        self.proteinValue = "0.0"
                    }
                    
                    else if self.carbsValue == "--"
                    {
                        self.carbsValue = "0.0"
                    }
                    
                    self.caloriesArray[i] = (self.setFoodCalories(Double(self.proteinValue)!, fatValue: Double(self.fatValue)!, carbsValue: Double(self.carbsValue)!))
       
                    
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
                i = i + 1
            }
        }
        
    }
    
    func logCaloriesButtonTapped(sender: UIButton)
    {
        var caloriesEntered = caloriesTextField.text!
        
        if caloriesEntered.isEmpty
        {
            caloriesEntered = String(0)
        }
        
        caloriesEntered = String(Int(caloriesEntered)! + caloriesIn)
        
        //don't forget to import Alamofire and SwiftyJSON
        
        //endpoint to database you want to post to
        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/\(logDate)"
        
        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
        //Format is = "Field": value
        let newPost = ["caloriesIn": caloriesEntered, "caloriesOut":caloriesOut,"logDate":logDate,"miles":miles,"steps":steps,"userId":userId,"weight":weight]
        
        //Creating the request to post the newPost JSON var.
        Alamofire.request(.PUT, postsEndpoint, parameters: newPost as? [String : AnyObject], encoding: .JSON)
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /posts/1")
                    print(response.result.error!)
                    return
                }
                
                if let value: AnyObject = response.result.value {
                    // handle the results as JSON, without a bunch of nested if loops
                    // this might not return anything here, but check the DB just in case. It might post anyway
                    let post = JSON(value)
                    print("The post is: " + post.description)
                }
        }
        
        self.tabBarController?.selectedIndex = 0
        
    }

    
       
    //--------------------
    // Set Food Calories
    //--------------------
    
    // This function calculates the total calories per serving in a formula
    func setFoodCalories(proteinValue: Double, fatValue: Double, carbsValue: Double) -> String
    {
        // Calculate the calories per serving from those 3 values
        var caloriesPerServing = 0.0
        
        caloriesPerServing = ((fatValue) * 9) + ((carbsValue) * 4) + ((proteinValue) * 4)
        
        return String(Int(caloriesPerServing))
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if filteredFoodItemArray.count == 0 && self.resultsSearchController.active == false{
            let duration: NSTimeInterval = 0.5
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.logCaloriesButton.frame = CGRectMake(
                    self.logCaloriesButton.frame.origin.x,
                    self.logCaloriesButton.frame.origin.y + 390,
                    self.logCaloriesButton.frame.size.width,
                    self.logCaloriesButton.frame.size.height)
            })
        }
    }
    
    // Clears the table when the user has finished searching
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        self.filteredFoodItemArray.removeAll(keepCapacity: false)
        self.foodItemArray.removeAll(keepCapacity: false)
        removeLinesFromTable()
        let duration: NSTimeInterval = 0.5
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.logCaloriesButton.frame = CGRectMake(
                self.logCaloriesButton.frame.origin.x,
                self.logCaloriesButton.frame.origin.y - 390,
                self.logCaloriesButton.frame.size.width,
                self.logCaloriesButton.frame.size.height)
        })
        self.nutritionFoodTableView.reloadData()
       
    }
    
    // Indicates that the search bar Search button has been clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        self.filteredFoodItemArray.removeAll(keepCapacity: false)
        self.foodItemArray.removeAll(keepCapacity: false)
    
        self.initialUSDAParse()
        self.parseNdbno()

        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchBar.text!)
        
        let foodNameArray = (self.foodItemArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.filteredFoodItemArray = foodNameArray as! [String]
    
        self.removeLinesFromTable()

        dispatch_async(dispatch_get_main_queue(),
        {
            self.nutritionFoodTableView.reloadData()
        })
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
        
        if self.resultsSearchController.active
        {
            return self.filteredFoodItemArray.count
        }
        
        return 0
    }
    
     /*
     ---------------------------------
     MARK: - TableViewDelegate Methods
     ---------------------------------
     */
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row: Int = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("foodItems", forIndexPath: indexPath)
        
        //dispatch_async(GlobalUserInitiatedQueue)
        //{
            if self.resultsSearchController.active
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    cell.textLabel!.text = self.filteredFoodItemArray[row]
                    
                    if self.caloriesArray[row] == "" || self.foodSizeMeasureArray[row] == ""
                    {
                        cell.detailTextLabel!.text = "Data downloading. please pull down to refresh."
                    }
                    
                    else
                    {
                        cell.detailTextLabel!.text = "\(self.caloriesArray[row]) Calories in (\(self.foodSizeMeasureArray[row]))"
                    }
                    
                   cell.setNeedsLayout()
                   
                })
            }
            
            else
            {
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = ""
            }
        
       // }
        
        return cell
    }
    
    // Informs the table view delegate that the specified row is selected.
    // Once the row is selected, present the view controller associated with the nutrient information
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row: Int = indexPath.row    // Identify the row number
        
        dispatch_async(dispatch_get_main_queue())
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let foodNutritionViewController = storyboard.instantiateViewControllerWithIdentifier("nutritionFactsView") as! FoodNutritionViewController
            
            self.foodNameToPass = self.filteredFoodItemArray[row]
            self.foodServingSizeToPass = self.foodSizeMeasureArray[row]
            self.caloriesToPass = self.caloriesArray[row]
            self.ndbnoToPass = self.itemNumberArray[row]
            
            foodNutritionViewController.foodName = self.foodNameToPass
            foodNutritionViewController.servingSize = self.foodServingSizeToPass
            foodNutritionViewController.calories = self.caloriesToPass
            foodNutritionViewController.ndbno = self.ndbnoToPass
        
        
            self.presentViewController(foodNutritionViewController, animated: true, completion: nil)
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
     ---------------------------------
     MARK: - Keyboard Handling Methods
     ---------------------------------
     */
    
    // This method is invoked when the user taps the Done key on the keyboard
    @IBAction func keyboardDone(sender: UITextField) {
        
        // Once the text field is no longer the first responder, the keyboard is removed
        sender.resignFirstResponder()
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /*
         "A UITouch object represents the presence or movement of a finger on the screen for a particular event." [Apple]
         We store the UITouch object's unique ID into the local variable touch.
         */
        if let touch = touches.first {
            /*
             When the user taps within a text field, that text field becomes the first responder.
             When a text field becomes the first responder, the system automatically displays the keyboard.
             */
            
            // If caloriesTextField is first responder and the user did not touch the caloriesTextField
            if caloriesTextField.isFirstResponder() && (touch.view != caloriesTextField) {
                
                // Make caloriesTextField to be no longer the first responder.
                caloriesTextField.resignFirstResponder()
            }
        }
        super.touchesBegan(touches, withEvent:event)
    }

}