//
//  SeeRecipeFromScheduleViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/10/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

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
    
    var userId = 0
    
    // Initialize variables for the PUT request
    var caloriesIn = 0
    var caloriesOut = 0
    var miles = 0.0
    var steps = 0
    var weight = 0.0
    var logDate = 0
    var epochTime = 0

    
    // Initialize array to pass so that the tableview can populate the cells
    var nutritionTitleArray = [String]()
    var nutritionDataArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = recipeName
        getRecipeButton.layer.cornerRadius = 8
        
        userId = applicationDelegate.userAccountInfo["id"] as! Int
        
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
        
        let date: NSDate = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate = cal.startOfDayForDate(date)
        epochTime = Int(newDate.timeIntervalSince1970)
        parseProgressForSpecificDate(epochTime)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    func addCalories(sender: AnyObject)
    {
        calories += caloriesIn
        
        //endpoint to database you want to post to
        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/\(epochTime)"
        
        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
        //Format is = "Field": value
        let newPost = ["caloriesIn": calories, "caloriesOut":caloriesOut,"logDate":logDate,"miles":miles,"steps":steps,"userId":userId,"weight":weight]
        
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
        
        self.navigationController?.popViewControllerAnimated(true)
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
