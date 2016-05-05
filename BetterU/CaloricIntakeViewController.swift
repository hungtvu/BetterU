//
//  CaloricIntakeViewController.swift
//  BetterU
//
//  Created by Allan Chua on 4/19/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Foundation
import SwiftChart
import KDCircularProgress

class CaloricIntakeViewController: UIViewController, UINavigationBarDelegate {
        
    var hasOpenedProgress = false
    
    @IBOutlet var containerViewA: UIView!
    @IBOutlet var containerViewB: UIView!
    @IBOutlet var containerViewC: UIView!
    /*
     @IBOutlet weak var chart: Chart!
     @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
     @IBOutlet weak var label: UILabel!
     private var labelLeadingMarginInitialConstant: CGFloat!
     
     var selectedChart = 0
     
     var CoolBeans = [Float]()*/
    override func viewDidLoad() {
        //  dataOutputWeek()
        //print(weekLabel())
        //  HealthKitHelper().weeklySteps1()
        // labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        //  NSThread.sleepForTimeInterval(0.10)
        super.viewDidLoad()
        
        if hasOpenedProgress
        {
            
            /* Changes the status bar color to the navigation bar's color */
            let statusBar = UIView(frame:
                CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
            statusBar.backgroundColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
            self.view.addSubview(statusBar)
            
            // Create the navigation bar
            let navigationBar = UINavigationBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44)) // Offset by 20 pixels vertically to take the status bar into account
            
            navigationBar.barTintColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            navigationBar.translucent = false
            navigationBar.delegate = self;
            
            // Create a navigation item with a title
            let navigationItem = UINavigationItem()
            navigationItem.title = "Caloric Intake"
            
            
            // Create a custom button with the checkmark image
            let leftButton =  UIBarButtonItem(title: "< Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(StepsTakenViewController.backButtonTapped(_:)));
            
            navigationItem.leftBarButtonItem = leftButton
            
            navigationBar.items = [navigationItem]
            
            self.view.addSubview(navigationBar)
            
            /* Creation of a segmented control programmatically
             
             * NOTE: we want to create another segmented control because when the view gets pushed from the exploding menu,
             * the caloric intake view control will hide the original calendarSegmentedControl behind its custom navigation bar.
             * There are 2 options to go about doing this:
             * 1. Remove all of the constraints from the view itself so that we can position the original calendar segmented
             * control downwards. (This requires extensive constraints removal and re-adding)
             * 2. Make the original segmented control disappear and create another one with the same functionality in a
             * different position. (This is much much easier than the alternative)
             
             */
            
            // Initialize segmented control titles
            let items = ["Day", "Week", "Month"]
            
            // Creation of our new custom segmented control
            let customSegmentedControl = UISegmentedControl(items: items)
            customSegmentedControl.selectedSegmentIndex = 0
            customSegmentedControl.layer.cornerRadius = 5
            customSegmentedControl.backgroundColor = UIColor.whiteColor()
            customSegmentedControl.tintColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
            
            // Adds the target so that we can create the same functionality as the original
            customSegmentedControl.addTarget(self, action: #selector(StepsTakenViewController.changeViews(_:)), forControlEvents: .ValueChanged)
            
            // Positions the new segmented control at the particular position and size
            customSegmentedControl.frame = CGRectMake(
                customSegmentedControl.frame.origin.x + 20,
                customSegmentedControl.frame.origin.y + 74,
                self.view.frame.size.width - 40,
                customSegmentedControl.frame.size.height)
            
            // Adds the segmented control to the view
            self.view.addSubview(customSegmentedControl)
            
        }
        
        
    }
    
    func changeViews(sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex {
            
        case 0:
            self.containerViewA.alpha = 1
            self.containerViewB.alpha = 0
            self.containerViewC.alpha = 0
        case 1:
            self.containerViewA.alpha = 0
            self.containerViewB.alpha = 1
            self.containerViewC.alpha = 0
        case 2:
            self.containerViewA.alpha = 0
            self.containerViewB.alpha = 0
            self.containerViewC.alpha = 1
            
        default:
            
            break
        }
        
    }
    
    func backButtonTapped(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func intervalChanged(sender: AnyObject) {
        switch sender.selectedSegmentIndex {
            
        case 0:
            self.containerViewA.alpha = 1
            self.containerViewB.alpha = 0
            self.containerViewC.alpha = 0
        case 1:
            self.containerViewA.alpha = 0
            self.containerViewB.alpha = 1
            self.containerViewC.alpha = 0
        case 2:
            self.containerViewA.alpha = 0
            self.containerViewB.alpha = 0
            self.containerViewC.alpha = 1
              
        default:
            
            break
        }
    }

        
}
