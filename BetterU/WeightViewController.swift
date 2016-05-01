//
//  WeightViewController.swift
//  BetterU
//
//  Created by Mukund Katti on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Foundation
import SwiftChart

class WeightViewController: UIViewController, UINavigationBarDelegate {
    
    @IBOutlet var containerB: UIView!
    @IBOutlet var containerC: UIView!
    var goalWeight: Double = 0
    var currentWeight: Double = 0
    
    var hasOpenedProgress = false
    
    // This method gets called first when the view is shown
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Weight"
        
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
            navigationItem.title = "Weight"
            
            
            // Create a custom button with the checkmark image
            let leftButton =  UIBarButtonItem(title: "< Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(WeightViewController.backButtonTapped(_:)));
            
            navigationItem.leftBarButtonItem = leftButton
            
            navigationBar.items = [navigationItem]
            
            self.view.addSubview(navigationBar)
            
            // Makes the original segmented control disappear
            
            /* Creation of a segmented control programmatically
             
             * NOTE: we want to create another segmented control because when the view gets pushed from the exploding menu,
             * the steps taken view control will hide the original calendarSegmentedControl behind its custom navigation bar.
             * There are 2 options to go about doing this:
             * 1. Remove all of the constraints from the view itself so that we can position the original calendar segmented
             * control downwards. (This requires extensive constraints removal and re-adding)
             * 2. Make the original segmented control disappear and create another one with the same functionality in a
             * different position. (This is much much easier than the alternative)
             
             */
            
            // Initialize segmented control titles
            let items = ["Week", "Month"]
            
            // Creation of our new custom segmented control
            let customSegmentedControl = UISegmentedControl(items: items)
            customSegmentedControl.selectedSegmentIndex = 0
            customSegmentedControl.layer.cornerRadius = 5
            customSegmentedControl.backgroundColor = UIColor.whiteColor()
            customSegmentedControl.tintColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
            
            // Adds the target so that we can create the same functionality as the original
            customSegmentedControl.addTarget(self, action: #selector(WeightViewController.changeViews(_:)), forControlEvents: .ValueChanged)
            
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
            self.containerB.alpha = 0
            self.containerC.alpha = 1
        case 1:
            self.containerB.alpha = 1
            self.containerC.alpha = 0
            
        default:
            
            break
        }
        
    }
    
    func backButtonTapped(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func intervalChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
            
            
        case 0:
            self.containerB.alpha = 0
            self.containerC.alpha = 1
        case 1:
            self.containerB.alpha = 1
            self.containerC.alpha = 0
            
            
            
        default:
            
            break
        }
        
    }
}

