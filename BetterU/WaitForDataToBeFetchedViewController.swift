//
//  WaitForDataToBeFetchedViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/20/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class WaitForDataToBeFetchedViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var hasDataBeenFetched = false
    
    var exerciseNameToPass = ""
    var equipmentNameToPass = ""
    var muscleGroupNameToPass = ""
    var exerciseDescriptionToPass = ""
    var exerciseIdToPass = 0
    var musclePrimaryIdArray = [Int]()
    var muscleSecondaryIdArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        
        if hasDataBeenFetched
        {
            self.performSegueWithIdentifier("showExerciseList", sender: self)
            //activityIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showExerciseList"
        {
            let parentExerciseView: ParentExerciseInfoViewController = segue.destinationViewController as! ParentExerciseInfoViewController
            
            parentExerciseView.exerciseName = self.exerciseNameToPass
            parentExerciseView.equipmentName = self.equipmentNameToPass
            parentExerciseView.muscleGroupName = self.muscleGroupNameToPass
            parentExerciseView.exerciseDescription = self.exerciseDescriptionToPass
            parentExerciseView.exerciseId = self.exerciseIdToPass
            parentExerciseView.musclePrimaryIdArray = self.musclePrimaryIdArray
            parentExerciseView.muscleSecondaryIdArray = self.muscleSecondaryIdArray
        }
    }
    

}
