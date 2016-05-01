//
//  ExercisesFromMuscleGroupTableViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/18/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class ExercisesFromMuscleGroupTableViewController: UITableViewController {

    var exerciseId = 0
    
    var currentPageNumber = 1
    var isPageRefreshing = false
    
    var equipmentIdArray = [Int]()
    
    var equipmentIdFromParsedJson = [Int]()
    var equipmentNameFromParsedJson = [String]()
    var equipmentId_Dict_equipmentName = [Int: String]()
    
    var muscleGroupImage = UIImage()
    var hasDataBeenFetched = false
    
    // Initialize variables that are storage for the required items to be passed down
    var exerciseNameArray = [String]()
    var equipmentNameValueArray = [String]()
    var exerciseDescriptionArray = [String]()
    var exerciseIdFromCategoryArray = [Int]()
    var musclePrimaryIdArray = [[Int]]()
    var muscleSecondaryIdArray = [[Int]]()
    
    // Initialize variables that are to be passed down to the next view
    var exerciseNameToPass = ""
    var equipmentNameToPass = ""
    var muscleGroupName = ""
    var exerciseDescriptionToPass = ""
    var muscleGroupNameToPass = ""
    var exerciseIdToPass = 0
    var musclePrimaryIdToPass = [Int]()
    var muscleSecondaryIdToPass = [Int]()
    var muscleGroupImageToPass = UIImage()
    
    var exerciseShown = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = muscleGroupName
        removeLines()
        parseEquipmentsFromId()
        parseExercise(currentPageNumber)
        
        exerciseShown = [Bool](count: 300, repeatedValue: false)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
       
    }
    
    func removeLines()
    {
       
        
        if (exerciseNameArray.count == 0)
        {
            // Remove extra lines from the table view
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            // Create a label that tells the user to pull up
            let label = UILabel(frame: CGRectMake(0, 0, 400, 100))
            label.numberOfLines = 0
            label.center = CGPointMake(185, 250)
            label.textAlignment = NSTextAlignment.Center
            label.text = "Please pull up to reveal more items."
            self.view.addSubview(label)
            
        }
            
        // Once there is an item in the array
        else
        {
            // Add extra lines from the table view
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
            // Removes the text and button from the view
            for subview in self.view.subviews
            {
                if (subview is UILabel)
                {
                    subview.removeFromSuperview()
                }
            }
            
        }
        

    }
    
    
    func parseExercise(currentPage: Int)
    {
        hasDataBeenFetched = false
        dispatch_async(GlobalUserInitiatedQueue)
        {
            // Since there are only 18 pages, the data must stop parsing when we hit the max amount of pages
            if currentPage < 19
            {
                let apiUrl = "https://wger.de/api/v2/exercise/?page=\(currentPage)"
                
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
                        var resultsDictFromArray = NSDictionary()
                        var exerciseCategoryId = [Int]()
                        var languageId = 0
                        var musclePrimaryId = [Int]()
                        var muscleSecondaryId = [Int]()
                        
                        var i = 0
                        while (i < resultsArray.count)
                        {
                            resultsDictFromArray = resultsArray[i] as! NSDictionary
                            exerciseCategoryId.append(resultsDictFromArray["category"] as! Int)
                            languageId = (resultsDictFromArray["language"] as? Int)!
                            
                            if (exerciseCategoryId[i] == self.exerciseId && languageId == 2)
                            {
                                self.exerciseNameArray.append(resultsDictFromArray["name"] as! String)
                                self.exerciseIdFromCategoryArray.append(resultsDictFromArray["id"] as! Int)
                                self.exerciseDescriptionArray.append(resultsDictFromArray["description"] as! String)
                                
                                let musclePrimary = resultsDictFromArray["muscles"] as! [Int]
                                let muscleSecondary = resultsDictFromArray["muscles_secondary"] as! [Int]
                                
                                var musclePrimaryIndex = 0
                                while (musclePrimaryIndex < musclePrimary.count)
                                {
                                    musclePrimaryId.append(musclePrimary[musclePrimaryIndex])
                                    musclePrimaryIndex = musclePrimaryIndex + 1
                                }
                                
                                var muscleSecondaryIndex = 0
                                while (muscleSecondaryIndex < muscleSecondary.count)
                                {
                                    muscleSecondaryId.append(muscleSecondary[muscleSecondaryIndex])
                                    muscleSecondaryIndex = muscleSecondaryIndex + 1
                                }
                                
                                self.musclePrimaryIdArray.append(musclePrimaryId)
                                self.muscleSecondaryIdArray.append(muscleSecondaryId)
                                
                                let equipments = resultsDictFromArray["equipment"] as! NSArray
                                
                                if equipments.count == 0
                                {
                                    self.equipmentNameValueArray.append("none (bodyweight exercise)")
                                }
                            
                                var j = 0
                                self.equipmentIdArray.removeAll(keepCapacity: false)
                                while (j < equipments.count)
                                {
                                    self.equipmentIdArray.append(equipments[j] as! Int)
                                    
                                    if let equipmentNameValue = self.equipmentId_Dict_equipmentName[self.equipmentIdArray[j]]
                                    {
                                        self.equipmentNameValueArray.append(equipmentNameValue)
                                    }
                                    
                                    j = j + 1
                                }
                            }
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
        }
        hasDataBeenFetched = true
    }
    
    func parseEquipmentsFromId()
    {
        let apiUrl = "https://wger.de/api/v2/equipment/"
        
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
                
                let results = jsonDataDictionary!["results"] as! NSArray
                var equipmentDictFromResults = NSDictionary()
                
                var i = 0
                while (i < results.count)
                {
                    equipmentDictFromResults = results[i] as! NSDictionary
                    
                    equipmentIdFromParsedJson.append(equipmentDictFromResults["id"] as! Int)
                    equipmentNameFromParsedJson.append(equipmentDictFromResults["name"] as! String)
                    
                    equipmentId_Dict_equipmentName[equipmentIdFromParsedJson[i]] = equipmentNameFromParsedJson[i]
                    
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
    
    // Animates table cell
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if exerciseShown[indexPath.row] == false
        {
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animateWithDuration(1.0, animations: { 
                cell.layer.transform = CATransform3DIdentity
            })
            
            exerciseShown[indexPath.row] = true
        }
    }
        
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
        {
            if !isPageRefreshing
            {
                isPageRefreshing = true
                removeLines()
                currentPageNumber = currentPageNumber + 1
                parseExercise(currentPageNumber)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
        isPageRefreshing = false
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseNameArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let row: Int = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("exercisesCell")! as UITableViewCell
        
        cell.textLabel!.text! = self.exerciseNameArray[row]
        cell.detailTextLabel!.text! = self.equipmentNameValueArray[row]
        cell.imageView!.image = muscleGroupImage
        
        return cell
    }
    
    // Informs the table view delegate that the user tapped the Detail Disclosure button
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        let rowNumber: Int = indexPath.row    // Identify the row number
        if hasDataBeenFetched
        {
            exerciseNameToPass = exerciseNameArray[rowNumber]
            equipmentNameToPass = equipmentNameValueArray[rowNumber]
            exerciseDescriptionToPass = exerciseDescriptionArray[rowNumber]
            muscleGroupNameToPass = muscleGroupName
            exerciseIdToPass = exerciseIdFromCategoryArray[rowNumber]
            musclePrimaryIdToPass = musclePrimaryIdArray[rowNumber]
            muscleSecondaryIdToPass = muscleSecondaryIdArray[rowNumber]
            muscleGroupImageToPass = muscleGroupImage
            
            performSegueWithIdentifier("showActivityIndicator", sender: self)
        }
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showActivityIndicator"
        {
            let waitForDataToFetchView: WaitForDataToBeFetchedViewController = segue.destinationViewController as! WaitForDataToBeFetchedViewController
            
            waitForDataToFetchView.exerciseNameToPass = self.exerciseNameToPass
            waitForDataToFetchView.equipmentNameToPass = self.equipmentNameToPass
            waitForDataToFetchView.muscleGroupNameToPass = self.muscleGroupNameToPass
            waitForDataToFetchView.exerciseDescriptionToPass = self.exerciseDescriptionToPass
            waitForDataToFetchView.exerciseIdToPass = self.exerciseIdToPass
            waitForDataToFetchView.hasDataBeenFetched = self.hasDataBeenFetched
            waitForDataToFetchView.musclePrimaryIdArray = self.musclePrimaryIdToPass
            waitForDataToFetchView.muscleSecondaryIdArray = self.muscleSecondaryIdToPass
            waitForDataToFetchView.muscleGroupImageToPass = self.muscleGroupImageToPass
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
    
}
