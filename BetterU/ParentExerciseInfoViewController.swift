//
//  ParentExerciseInfoViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/20/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class ParentExerciseInfoViewController: UIViewController {

    @IBOutlet var exerciseNameLabel: UILabel!
    
    @IBOutlet var descriptionContainerView: UIView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var muscleContainerView: UIView!
    
    var exerciseName = ""
    var equipmentName = ""
    var muscleGroupName = ""
    var exerciseDescription = ""
    var exerciseId = 0
    
    var imageStringArray = [String]()
    var musclePrimaryIdArray = [Int]()
    var muscleSecondaryIdArray = [Int]()
    var muscleId_dict_muscleName = [Int: String]()
    var muscleName_dict_isFront = [String: Bool]()
    
    var primaryMuscleName = [String]()
    var secondaryMuscleName = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(exerciseId)
        
        exerciseNameLabel.text! = exerciseName
        
        // Set up the Add button on the right of the navigation bar to call the addRecipe method when tapped
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ParentExerciseInfoViewController.addExercise(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        // Create a custom back button on the navigation bar
        // This will let us pop the current view controller to the one before the previous view
        // This is needed so that the user does not have to see the previous loading screen
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
        myBackButton.addTarget(self, action: #selector(ParentExerciseInfoViewController.popBackTwoViews(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("< Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem = myCustomBackButtonItem

    }
    
    func popBackTwoViews(sender: UIBarButtonItem)
    {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
    }
    
    func addExercise(sender: AnyObject)
    {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       // parseMuscle()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Display the description on the screen
    @IBAction func descriptionButtonTapped(sender: UIButton)
    {
        
        UIView.animateWithDuration(0.5, animations:
        {
            self.descriptionContainerView.alpha = 1
            self.imageContainerView.alpha = 0
            self.muscleContainerView.alpha = 0
        })
        
       
    }
    
    // Display the image of the exercise on the screen
    @IBAction func imageButtonTapped(sender: UIButton)
    {
        UIView.animateWithDuration(0.5, animations:
        {
            self.descriptionContainerView.alpha = 0
            self.imageContainerView.alpha = 1
            self.muscleContainerView.alpha = 0
        })
    }
    
    // Display the muscle worked on the screen
    @IBAction func muscleButtonTapped(sender: UIButton)
    {
        UIView.animateWithDuration(0.5, animations:
        {
            self.descriptionContainerView.alpha = 0
            self.imageContainerView.alpha = 0
            self.muscleContainerView.alpha = 1
        })
    }
    
    func parseExerciseImage()
    {
        var page = 1
        while(page < 12) {
            let apiUrl = "https://wger.de/api/v2/exerciseimage/?page=\(page)"
            
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
                    var resultsDictFromArray = NSDictionary()
                    
                    var exerciseIdFromImage = 0
                    var imageString = ""
                    var exerciseIdFromImageArray = [Int]()

                    
                    var i = 0
                    while(i < results.count)
                    {
                        resultsDictFromArray = results[i] as! NSDictionary
                        exerciseIdFromImage = resultsDictFromArray["exercise"] as! Int
                        exerciseIdFromImageArray.append(exerciseIdFromImage)
                        
                        if exerciseIdFromImageArray[i] == self.exerciseId
                        {
                            imageString = resultsDictFromArray["image"] as! String
                            imageStringArray.append(imageString)
                        }
                        
                        if imageStringArray.count == 2
                        {
                            break
                        }
                        i = i + 1
                    }
                    break
                    
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
            page = page + 1
        }
        
        
    }
    
    func parseMuscle()
    {
        let apiUrl = "https://wger.de/api/v2/muscle/"
        
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
                var resultsDictFromArray = NSDictionary()
                
                var i = 0
                while (i < results.count)
                {
                    resultsDictFromArray = results[i] as! NSDictionary
                    
                    // Grabs the ID of the muscle as a key and the name of the muscle as the value
                    muscleId_dict_muscleName[resultsDictFromArray["id"] as! Int] = resultsDictFromArray["name"] as? String
                    muscleName_dict_isFront[resultsDictFromArray["name"] as! String] = resultsDictFromArray["is_front"] as? Bool

                    i = i + 1
                }
                
                var j = 0
                while (j < musclePrimaryIdArray.count)
                {
                    if let muscleName = muscleId_dict_muscleName[musclePrimaryIdArray[j]]
                    {
                        primaryMuscleName.append(muscleName)
                    }

                    j = j + 1
                }
                
                var k = 0
                while (k < muscleSecondaryIdArray.count)
                {
                    if let muscleName = muscleId_dict_muscleName[muscleSecondaryIdArray[k]]
                    {
                        secondaryMuscleName.append(muscleName)
                    }
                    
                    k = k + 1
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



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "descriptionView"
        {
            let descriptionViewController: DescriptionViewController = segue.destinationViewController as! DescriptionViewController
            
            descriptionViewController.categoryName = self.muscleGroupName
            descriptionViewController.equipmentName = self.equipmentName
            descriptionViewController.instructions = self.exerciseDescription
        }
        
        else if segue.identifier == "showImage"
        {
            let exerciseImageView: ExerciseImageViewController = segue.destinationViewController as! ExerciseImageViewController
            
            parseExerciseImage()
            if self.imageStringArray.count > 0
            {
                exerciseImageView.image1String = self.imageStringArray[0]
                exerciseImageView.image2String = self.imageStringArray[1]
            }
        }
        
        else if segue.identifier == "showMuscle"
        {
            let exerciseMuscleView: ExerciseMuscleViewController = segue.destinationViewController as! ExerciseMuscleViewController
            
            parseMuscle()

            if self.primaryMuscleName.count > 0
            {
                exerciseMuscleView.primaryMuscleName.appendContentsOf(self.primaryMuscleName)
            }
            
            if self.secondaryMuscleName.count > 0
            {
                exerciseMuscleView.secondaryMuscleName.appendContentsOf(self.secondaryMuscleName)
            }

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
