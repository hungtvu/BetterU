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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        mealPlanViewController = storyboard?.instantiateViewControllerWithIdentifier("mealPlanView") as! MealPlanViewController
        
        self.addChildViewController(mealPlanViewController)
        mealPlanViewController.willMoveToParentViewController(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showComponent(sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 0
        {
            UIView.animateWithDuration(0.5, animations:
                {
                    self.exerciseContainerView.alpha = 0
                    self.mealContainerView.alpha = 1
                    self.navigationItem.leftBarButtonItem = self.editButtonItem()
                    //self.mealPlanViewController.parentViewController?.navigationItem.leftBarButtonItem = self.mealPlanViewController.editButtonTable
            })
        }
            
        else
        {
            UIView.animateWithDuration(0.5, animations:
                {
                    self.exerciseContainerView.alpha = 1
                    self.mealContainerView.alpha = 0
                    self.navigationItem.leftBarButtonItem = nil
            })
        }
    }
    
}