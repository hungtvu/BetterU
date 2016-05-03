//
//  HomeTableViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/1/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var weightInLbs: Int = 0
    var tableViewRowHeight: CGFloat = 117.0
    var totalCaloriesBurned: Double = 0.0
    var totalMilesWalked: Double = 0.0
    var stepsCount: Int = 0
    
    var id = 0
    
    var context: NSManagedObjectContext!
    var isAscending = true

    // Initialize variables for the PUT request
    var caloriesIn = 0
    var caloriesOut = 0
    var miles = 0.0
    var steps = 0
    var weight = 0.0
    var logDate = 0
    var epochTime = 0

    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Home"
        
        id = applicationDelegate.userAccountInfo["id"] as! Int
        
        let date: NSDate = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate = cal.startOfDayForDate(date)
        epochTime = Int(newDate.timeIntervalSince1970)
        parseProgressForSpecificDate(epochTime)
        
        HealthKitHelper().recentSteps() { steps, error in
            
            // Since there are 2112 steps in one mile, we will divide steps taken by 2112
            let milesFromSteps: Double = steps/2112
            
            // Calculate the amount of calories burned per mile
            // By multiplying the user's weight by 0.57, we can get that.
            // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
            let caloriesBurnedPerMile = 0.57 * Double(self.weightInLbs)
            
            // Divide the number of calories that are burned per mile by number of steps to walk a mile
            let caloriesPerStep = caloriesBurnedPerMile/2112
            
            // Calculating calories burned by multiplying the total steps to calories burned per steps
            let totalCaloriesBurnedFromSteps = steps * caloriesPerStep + Double(self.caloriesOut)
            
            // Grabbing the necessary values and assigning it to a variable
            self.totalCaloriesBurned = round(totalCaloriesBurnedFromSteps * 10)/10
            self.totalMilesWalked = round(milesFromSteps * 100)/100
            self.stepsCount = Int(steps)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeTableViewController.reloadTable(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        parseJson()
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.tableView.reloadData()
        })
        
    }
    
    /* This method parses the json straight from the RESTful API services. Since the user's weight is grabbed and stored into a plist dictionary when the user enters the SignInViewController, it will not get updated until the user goes into that page again. Thus, we will need this method to update the user's most up to date information. (ie., a user decides to change their weight) */
    func parseJson()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/\(id)"
        
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
                
                /* {
                 DCSkipped = 1;
                 WCSkipped = 1;
                 activityGoal = "Very Active";
                 activityLevel = 0;
                 age = 20;
                 bmr = 1724;
                 dailyChallengeIndex = 4;
                 email = "jdoe@vt.edu";
                 firstName = John;
                 gender = M;
                 goalType = 4;
                 goalWeight = 130;
                 height = 65;
                 id = 1;
                 lastName = Doe;
                 password = password;
                 points = 0;
                 securityAnswer = Virginia;
                 securityQuestion = 3;
                 units = I;
                 username = jdoe;
                 weeklyChallengeIndex = 2;
                 weight = 155;
                 },
                 */
                let jsonDataDictInfo = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                // Grabs data from the JSON and stores it into the appropriate variable
                weightInLbs = jsonDataDictInfo["weight"] as! Int
                applicationDelegate.userAccountInfo.setValue(weightInLbs, forKey: "User Weight")
                
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
    
    func parseProgressForSpecificDate(dateInEpoch: Int)
    {
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(id)/\(dateInEpoch)"
        
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


    
    func reloadTable(sender: AnyObject)
    {
        parseJson()
        
        let date: NSDate = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate = cal.startOfDayForDate(date)
        epochTime = Int(newDate.timeIntervalSince1970)
        parseProgressForSpecificDate(epochTime)
        
        HealthKitHelper().recentSteps() { steps, error in
            
            // Since there are 2112 steps in one mile, we will divide steps taken by 2112
            let milesFromSteps: Double = steps/2112
            
            // Calculate the amount of calories burned per mile
            // By multiplying the user's weight by 0.57, we can get that.
            // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
            let caloriesBurnedPerMile = 0.57 * Double(self.weightInLbs)
            
            // Divide the number of calories that are burned per mile by number of steps to walk a mile
            let caloriesPerStep = caloriesBurnedPerMile/2112
            
            // Calculating calories burned by multiplying the total steps to calories burned per steps
            let totalCaloriesBurnedFromSteps = steps * caloriesPerStep + Double(self.caloriesOut)
            
            // Grabbing the necessary values and assigning it to a variable
            self.totalCaloriesBurned = round(totalCaloriesBurnedFromSteps * 10)/10
            self.totalMilesWalked = round(milesFromSteps * 100)/100
            self.stepsCount = Int(steps)
        }

        
        dispatch_async(dispatch_get_main_queue(),
        {
           
            self.tableView.reloadData()
            
            if (self.refreshControl!.refreshing)
            {
                self.refreshControl!.endRefreshing()
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // There is only one section in the table
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // This method tells you how many rows there are in each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // Asks the table view delegate to return the height of a given row.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return tableViewRowHeight
    }
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    // This method asks the tableView to populate the prototype cells with the necessary information
    // The cells are all custom cells. We did it this way because some value items had different properties
    // such as, the steps taken row only required an integer instead of a float. 
    // Furthermore, making each cell custom from each other prevents unnecessary crash in the code. Before, we
    // used arrays of strings and double under the HealthKitHelper method, the app would crash due to it not
    // populating the indices of the array in time. When that happens, we will get an index out of bounds error.
    // Making each cell custom, we don't have to worry about populating data through the use of arrays.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let row: Int = indexPath.row
        
        // Populating the calories burned row
        if row == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Calories")! as! HomeTableViewCell
        
            // Grab the row count from the indexPath in the cell
            cell.thumbnailImage!.image = UIImage(named: "CaloriesBurnedIcon")
            cell.valueLabel!.text = String(totalCaloriesBurned)
            cell.metricLabel!.text = "Cal."
            
            cell.setNeedsLayout()
            
            return cell
        }
            
        // Populating the steps taken row
        else if row == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Steps")! as! StepsTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "StepsIcon")
            cell.valueLabel!.text = String(stepsCount)
            cell.metricLabel!.text = "Steps"
            
            cell.setNeedsLayout()
            
            return cell
        }
        
        // Populating te miles walked row
        else if row == 2
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Miles")! as! MilesTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "runningManIcon")
            cell.valueLabel!.text = String(totalMilesWalked)
            cell.metricLabel!.text = "Miles"
            
            cell.setNeedsLayout()
            
            return cell
        }
        
        // Populating the weight row
        else if row == 3
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Weight")! as! WeightTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "weightIcon")
            cell.valueLabel!.text = String(weightInLbs)
            cell.metricLabel!.text = "lbs"
            
            cell.setNeedsLayout()
            
            return cell
        }
        
        // Populating the caloric intake row
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("CaloricIntake")! as! CaloricIntakeTableViewCell
            
            cell.thumbnailImage!.image = UIImage(named: "bananaIcon")
            cell.valueLabel!.text = String(caloriesIn)
            cell.metricLabel!.text = "In"
            
            cell.setNeedsLayout()
            
            return cell
        }
    }
    
    
   
}