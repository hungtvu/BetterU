//
//  JournalViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class JournalViewController: UIViewController {
    
    @IBOutlet var exerciseContainerView: UIView!
    @IBOutlet var mealContainerView: UIView!
    
    @IBOutlet var mealOrExerciseControl: UISegmentedControl!
    
    var mealPlanViewController = MealPlanViewController()
    
    var exerciseView = ExerciseViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if mealOrExerciseControl.selectedSegmentIndex == 1
        {
            self.navigationItem.leftBarButtonItem!.title = ""
        }
        else
        {
            self.navigationItem.rightBarButtonItem!.title = ""
        }
    }
    
    @IBAction func showComponent(sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 0
        {
            UIView.animateWithDuration(0.5, animations:
            {
                self.exerciseContainerView.alpha = 0
                self.mealContainerView.alpha = 1
                self.navigationItem.rightBarButtonItem!.title = ""
                self.navigationItem.leftBarButtonItem!.title = "Edit Meal"
            })
        }
            
        else
        {
            UIView.animateWithDuration(0.5, animations:
            {
                self.exerciseContainerView.alpha = 1
                self.mealContainerView.alpha = 0
                self.navigationItem.leftBarButtonItem!.title = ""
                self.navigationItem.rightBarButtonItem!.title = "Edit Exercise"
                
            })
        }
    }
    
}