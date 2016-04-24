//
//  ExerciseMuscleViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/20/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class ExerciseMuscleViewController: UIViewController {

    @IBOutlet var frontalMuscleImageView: UIImageView!
    @IBOutlet var backMuscleImageView: UIImageView!
    @IBOutlet var muscleFrontalLabel: UILabel!
    @IBOutlet var muscleBackLabel: UILabel!
    
    var primaryMuscleName = [String]()
    var secondaryMuscleName = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if primaryMuscleName.count > 0
        {
            frontalMuscleImageView.image = UIImage(named: primaryMuscleName[0])
            var i = 0
            while (i < primaryMuscleName.count)
            {
                if !muscleFrontalLabel.text!.containsString("•\(primaryMuscleName[i])\n") {
                    muscleFrontalLabel.text! += "•\(primaryMuscleName[i])\n"
                }
                i = i + 1
            }
        }
        else
        {
             frontalMuscleImageView.image = UIImage(named: "NoFront")
        }
        
        if secondaryMuscleName.count > 0
        {
            backMuscleImageView.image = UIImage(named: secondaryMuscleName[0])
            
            var j = 0
            while (j < secondaryMuscleName.count)
            {
                if !muscleBackLabel.text!.containsString("•\(secondaryMuscleName[j])\n")
                {
                    muscleBackLabel.text! += "•\(secondaryMuscleName[j])\n"
                }
                j = j + 1
            }
        }
        else
        {
            backMuscleImageView.image = UIImage(named: "NoBack")
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


}
