//
//  SetActivityLevelViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/10/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SetActivityLevelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Initialize boolean arrays to allow logic in placing checkmarks next to each row selection
    var checkedInCurrentActivity = [Bool]()
    var checkedInGoalActivity = [Bool]()
    
    // Initialize object referencecs for the objects in the view controller
    @IBOutlet var currentActivityTable: UITableView!
    @IBOutlet var goalActivityTable: UITableView!
    @IBOutlet var saveButton: UIButton!
    
    // Initialize variables to pass downstream to the AccountDetailsViewController
    var selectedPathForCurrentActivity = String()
    var selectedPathForGoalActivity = String()
    
    // Initializing titles and subtitles for cells in different tables
    // The cellTitles are titles for the Current Activity Level table
    var cellTitles = ["Sedentary", "Lightly Active", "Active", "Very Active"]
    var cellSubtitles = ["I am exercising for less than 1 hour per week", "I am exercising for about 2-5 hours a week", "I am exercising for about 5-7 hours per week", "I am exercising for 8 or more hours per week"]
    
    var cellTitlesGoalActivity = ["Lightly Active", "Active", "Very Active"]
    var cellSubtitlesForGoalActivity = ["I want to spend some part of my day on my feet", "I want to spend more of my day being physical", "I want to spend most of my day getting physically healthier"]
    
    var currentActivityIndexPath = NSIndexPath()
    var currentActivityIndexFromDelegate: Int = 0
    var currentActivityIndex = 0
    
    var goalActivityFromDelegate = ""
    var goalActivityIndex = 0
    var goalActivityIndexPath = NSIndexPath()
    
    // Initialize more variables to update the backend. All variables will need to be updated no matter what
    var email = ""
    var firstName = ""
    var lastName = ""
    var age = 0
    var height = 0
    var weight = 0
    var gender = ""
    var heightFtCalculated = 0
    var heightInCalculated = 0
    var exp = 0
    var goalWeight = 0
    var id = 0
    var password = ""
    var username = ""
    var securityQuestion = 0
    var securityAnswer = ""
    var recipeIdLunch = ""
    var recipeIdDinner = ""
    var recipeIdSnacks = ""
    var recipeIdBreakfast = ""
    
    var heightInches = ""
    var heightFt = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.layer.cornerRadius = 8
        
        // Setting boolean arrays to be the same size as the table
        checkedInCurrentActivity = [false, false, false, false]
        checkedInGoalActivity = [false, false, false]
        
        // Grabbing variables from the plist
        email = applicationDelegate.userAccountInfo["Email"] as! String
        firstName = applicationDelegate.userAccountInfo["First Name"] as! String
        lastName = applicationDelegate.userAccountInfo["Last Name"] as! String
        age = applicationDelegate.userAccountInfo["Age"] as! Int
        height = applicationDelegate.userAccountInfo["Height"] as! Int
        weight = applicationDelegate.userAccountInfo["User Weight"] as! Int
        gender = applicationDelegate.userAccountInfo["Gender"] as! String
        
        exp = applicationDelegate.userAccountInfo["Exp"] as! Int
        goalWeight = applicationDelegate.userAccountInfo["Goal Weight"] as! Int
        id = applicationDelegate.userAccountInfo["id"] as! Int
        password = applicationDelegate.userAccountInfo["Password"] as! String
        username = applicationDelegate.userAccountInfo["Username"] as! String
        securityQuestion = applicationDelegate.userAccountInfo["Security Question"] as! Int
        securityAnswer = applicationDelegate.userAccountInfo["Security Answer"] as! String

        
        // Grabs the goal activity level from the application delegate as a string
        goalActivityFromDelegate = applicationDelegate.userAccountInfo["Activity Goal"] as! String
        
        selectedPathForGoalActivity = goalActivityFromDelegate
        
        // Check where the index lies in the row, then assign that index to an integer variable
        switch goalActivityFromDelegate
        {
            case "Lightly Active":
            goalActivityIndex = 0
            break
            
            case "Active":
            goalActivityIndex = 1
            break
            
            case "Very Active":
            goalActivityIndex = 2
            break
            
        default:
            break
        }
        
        // Grabs the current index of the current activity level from the application delegate
        currentActivityIndexFromDelegate = applicationDelegate.userAccountInfo["Current Activity Level"] as! Int
        
        // Replaces that index in the boolean array as true
        checkedInCurrentActivity[currentActivityIndexFromDelegate] = true
        checkedInGoalActivity[goalActivityIndex] = true
        
        // Grabs the index path for the row in the table as the index of the current activity
        currentActivityIndexPath = NSIndexPath(forRow: currentActivityIndexFromDelegate, inSection: 0)
        goalActivityIndexPath = NSIndexPath(forRow: goalActivityIndex, inSection: 0)
        
        // Auto selects that row within the table
        self.currentActivityTable.selectRowAtIndexPath(currentActivityIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        
        self.goalActivityTable.selectRowAtIndexPath(goalActivityIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        
        currentActivityIndex = currentActivityIndexFromDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        
        parseJson()
        
        selectedPathForGoalActivity = goalActivityFromDelegate
        
        // Check where the index lies in the row, then assign that index to an integer variable
        switch goalActivityFromDelegate
        {
        case "Lightly Active":
            goalActivityIndex = 0
            break
            
        case "Active":
            goalActivityIndex = 1
            break
            
        case "Very Active":
            goalActivityIndex = 2
            break
            
        default:
            break
        }
        
        // Replaces that index in the boolean array as true
        checkedInCurrentActivity[currentActivityIndexFromDelegate] = true
        checkedInGoalActivity[goalActivityIndex] = true
        
        // Grabs the index path for the row in the table as the index of the current activity
        currentActivityIndexPath = NSIndexPath(forRow: currentActivityIndexFromDelegate, inSection: 0)
        goalActivityIndexPath = NSIndexPath(forRow: goalActivityIndex, inSection: 0)
        
        // Auto selects that row within the table
        self.currentActivityTable.selectRowAtIndexPath(currentActivityIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        
        self.goalActivityTable.selectRowAtIndexPath(goalActivityIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        
        currentActivityIndex = currentActivityIndexFromDelegate
    }
  
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
                username = jsonDataDictInfo["username"] as! String
                password = jsonDataDictInfo["password"] as! String
                weight = jsonDataDictInfo["weight"] as! Int
                firstName = jsonDataDictInfo["firstName"] as! String
                lastName = jsonDataDictInfo["lastName"] as! String
                email = jsonDataDictInfo["email"] as! String
                age = jsonDataDictInfo["age"] as! Int
                gender = jsonDataDictInfo["gender"] as! String
                height = jsonDataDictInfo["height"] as! Int
                exp = jsonDataDictInfo["points"] as! Int
                currentActivityIndexFromDelegate = jsonDataDictInfo["activityLevel"] as! Int
                goalActivityFromDelegate = jsonDataDictInfo["activityGoal"] as! String
                goalWeight = jsonDataDictInfo["goalWeight"] as! Int
                id = jsonDataDictInfo["id"] as! Int
                securityQuestion = jsonDataDictInfo["securityQuestion"] as! Int
                securityAnswer = jsonDataDictInfo["securityAnswer"] as! String
                
                recipeIdBreakfast = jsonDataDictInfo["breakfast"] as! String
                recipeIdSnacks = jsonDataDictInfo["snack"] as! String
                recipeIdDinner = jsonDataDictInfo["dinner"] as! String
                recipeIdLunch = jsonDataDictInfo["lunch"] as! String

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

    
    @IBAction func saveButtonTapped(sender: UIButton)
    {
        
        var activityGoalToUse = ""
        var currentActivityLevelToUse = 0
        
        
        // If the user has changed their current activity level
        if currentActivityIndexPath.row != currentActivityIndex
        {
            currentActivityLevelToUse = currentActivityIndex
        }
        
        else
        {
            currentActivityLevelToUse = currentActivityIndexFromDelegate
        }
        
        // If the user has changed their goal activity level
        if goalActivityIndexPath.row != goalActivityIndex
        {
            activityGoalToUse = selectedPathForGoalActivity
        }
        
        else
        {
            activityGoalToUse = goalActivityFromDelegate
        }
        
        //don't forget to import Alamofire and SwiftyJSON
        
        //endpoint to database you want to post to
        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/\(id)"
        
        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
        //Format is = "Field": value
        let newPost = ["DCSkipped": 0, "WCSkipped": 0, "activityGoal": activityGoalToUse, "activityLevel": currentActivityLevelToUse, "age": age, "bmr": "testBMR", "dailyChallengeIndex": 0, "email": email, "firstName": firstName, "gender": gender, "goalType": 0, "goalWeight": goalWeight, "height": height, "id": id, "lastName": lastName, "password": password, "points": 0, "securityAnswer": securityAnswer, "securityQuestion": securityQuestion, "targetCalories": 0, "units": "I", "username": username, "weeklyChallengeIndex": 0, "weight": weight, "lunch": recipeIdLunch, "breakfast": recipeIdBreakfast, "dinner": recipeIdDinner, "snack": recipeIdSnacks]
        
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

        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    
    // Returns the number of sections in the tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // Returns the number of rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1
        {
            return 4
        }
        
        return 3
    }
    
    /*
     ------------------------------------
     Prepare and Return a Table View Cell
     ------------------------------------
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // grab row from indexpath
        let row: Int = indexPath.row
        
        if tableView.tag == 1 {
            
            let cell = currentActivityTable.dequeueReusableCellWithIdentifier("currentActivityCell",forIndexPath: indexPath) as UITableViewCell
            cell.textLabel!.text = cellTitles[row]
            cell.detailTextLabel!.text = cellSubtitles[row]
            if checkedInCurrentActivity[indexPath.row] == false {
                
                cell.accessoryType = .None
            }
            else if checkedInCurrentActivity[indexPath.row] == true {
                
                cell.accessoryType = .Checkmark
            }
            
            return cell
        }
            
        else {
            
            let cell = goalActivityTable.dequeueReusableCellWithIdentifier("goalActivityCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel!.text = cellTitlesGoalActivity[row]
            cell.detailTextLabel!.text = cellSubtitlesForGoalActivity[row]
            if checkedInGoalActivity[indexPath.row] == false {
                
                cell.accessoryType = .None
            }
            else if checkedInGoalActivity[indexPath.row] == true {
                
                cell.accessoryType = .Checkmark
            }
            
            return cell
        }
    }
    
    // Shows that the row in the table has been selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        // For the current activity level table view
        if tableView.tag == 1
        {
            selectedPathForCurrentActivity = cellTitles[indexPath.row]
            currentActivityIndex = indexPath.row
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if cell.accessoryType == .Checkmark
                {
                    cell.accessoryType = .None
                    checkedInCurrentActivity[indexPath.row] = false
                }
                else
                {
                    let newCell = tableView.cellForRowAtIndexPath(indexPath)
                    newCell!.accessoryType = .Checkmark
                    checkedInCurrentActivity[indexPath.row] = true
                }
            }
        }
        
        // For the goal activity level table view
        if tableView.tag == 2
        {
            selectedPathForGoalActivity = cellTitlesGoalActivity[indexPath.row]
            goalActivityIndex = indexPath.row
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if cell.accessoryType == .Checkmark
                {
                    cell.accessoryType = .None
                    checkedInGoalActivity[indexPath.row] = false
                }
                else
                {
                    let newCell = tableView.cellForRowAtIndexPath(indexPath)
                    newCell!.accessoryType = .Checkmark
                    checkedInGoalActivity[indexPath.row] = true
                }
            }
        }
    }


}
