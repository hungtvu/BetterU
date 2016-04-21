//
//  MuscleGroupViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/18/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class MuscleGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var muscleGroupTableView: UITableView!
    
    // WGER API Key:
    let apiKey = "ef824b68b91f55a12586152a8f1814cf0698a6b8"
    
    var muscleGroupArray = [String]()
    var exerciseIdArray = [Int]()
    var imageArray = [UIImage]()
    
    var resultsSearchController = UISearchController()
    
    var exerciseIdToPass = 0
    var muscleGroupNameToPass = ""
    var muscleGroupImageToPass = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Muscle Group"
        
        imageArray.append(UIImage(named: "absMuscle")!)
        imageArray.append(UIImage(named: "armMuscle")!)
        imageArray.append(UIImage(named: "backMuscle")!)
        imageArray.append(UIImage(named: "calvesMuscle")!)
        imageArray.append(UIImage(named: "chestMuscle")!)
        imageArray.append(UIImage(named: "legMuscle")!)
        imageArray.append(UIImage(named: "shoulderMuscle")!)
        
        self.resultsSearchController = UISearchController(searchResultsController: nil)
        self.resultsSearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.resultsSearchController.searchBar.delegate = self
        self.resultsSearchController.searchBar.sizeToFit()

        self.resultsSearchController.searchBar.placeholder = "Search for an exercise"
        //self.navigationItem.titleView = self.resultsSearchController.searchBar
        self.resultsSearchController.hidesNavigationBarDuringPresentation = false;
        self.muscleGroupTableView.tableHeaderView = self.resultsSearchController.searchBar
        
        parseMuscleGroup()
        //parseExercise()
    }
    
    func parseMuscleGroup()
    {
        let apiUrl = "https://wger.de/api/v2/exercisecategory/"
    
        // Convert URL to NSURL
        let url = NSURL(string: apiUrl)
        
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
                
                let resultsArray = jsonDataDictionary!["results"] as! NSArray
                var resultsInfoDictFromArray = NSDictionary()
                
                var i = 0
                while (i < resultsArray.count)
                {
                    resultsInfoDictFromArray = resultsArray[i] as! NSDictionary
                    muscleGroupArray.append(resultsInfoDictFromArray["name"] as! String)
                    exerciseIdArray.append(resultsInfoDictFromArray["id"] as! Int)
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
        
       return muscleGroupArray.count
    }
    
    /*
     ---------------------------------
     MARK: - TableViewDelegate Methods
     ---------------------------------
     */
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row: Int = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("muscleCell")! as UITableViewCell
        
        cell.textLabel!.text = muscleGroupArray[row]
        cell.imageView!.image = imageArray[row]
        
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
        
        self.muscleGroupTableView.deselectRowAtIndexPath(indexPath, animated: true)
        exerciseIdToPass = exerciseIdArray[row]
        muscleGroupNameToPass = muscleGroupArray[row]
        muscleGroupImageToPass = imageArray[row]
        
        
       
        performSegueWithIdentifier("showExercises", sender: self)
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showExercises"
        {
            let exercisesFromMuscleGroup: ExercisesFromMuscleGroupTableViewController = segue.destinationViewController as! ExercisesFromMuscleGroupTableViewController
            
            exercisesFromMuscleGroup.exerciseId = self.exerciseIdToPass
            exercisesFromMuscleGroup.muscleGroupName = self.muscleGroupNameToPass
            exercisesFromMuscleGroup.muscleGroupImage = self.muscleGroupImageToPass
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
