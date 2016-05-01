//
//  StepsTakenViewController.swift
//  BetterU
//
//  Created by Travis Lu on 4/7/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//


import UIKit
import SwiftChart
import Foundation

class StepsTakenViewController: UIViewController, UINavigationBarDelegate {
    
    var hasOpenedProgress = false
    
    var barTitle = ""

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
            navigationItem.title = barTitle
            
            
            // Create a custom button with the checkmark image
           let leftButton =  UIBarButtonItem(title: "< Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(StepsTakenViewController.backButtonTapped(_:)));
            
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
        
        
        /*
         // Draw the chart selected from the TableViewController
         
         // print(CoolBeans)
         chart.delegate = self
         
         // Simple chart
         let series = ChartSeries(CoolBeans)
         // series.color = ChartColors.greenColor()
         series.area = true
         chart.addSeries(series)
         //  chart.xLabelsFormatter = "Day"
         let labelsAsString = weekLabel()
         chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
         return labelsAsString[labelIndex]
         }
         
         
         }
         override func viewDidAppear(animated: Bool) {
         
         }*/
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
    /*
     func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
     for (seriesIndex, dataIndex) in indexes.enumerate() {
     if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
     //print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
     let numberFormatter = NSNumberFormatter()
     numberFormatter.minimumFractionDigits = 0
     numberFormatter.maximumFractionDigits = 0
     label.text = numberFormatter.stringFromNumber(Int(value))! + " Steps"
     
     // Align the label to the touch left position, centered
     var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
     
     // Avoid placing the label on the left of the chart
     if constant < labelLeadingMarginInitialConstant {
     constant = labelLeadingMarginInitialConstant
     }
     
     // Avoid placing the label on the right of the chart
     let rightMargin = chart.frame.width - label.frame.width
     if constant > rightMargin {
     constant = rightMargin
     }
     
     labelLeadingMarginConstraint.constant = constant
     
     }
     }
     }
     
     func didFinishTouchingChart(chart: Chart) {
     label.text = ""
     labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
     }
     
     func dataOutputWeek()->[Float]
     {
     HealthKitHelper().weeklySteps1() { stepLog, error in
     
     // Since there are 2112 steps in one mile, we will divide steps taken by 2112
     
     // Calculate the amount of calories burned per mile
     // By multiplying the user's weight by 0.57, we can get that.
     // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
     
     // Divide the number of calories that are burned per mile by number of steps to walk a mile
     // let caloriesPerStep = caloriesBurnedPerMile/2112
     
     // Calculating calories burned by multiplying the total steps to calories burned per steps
     //let totalCaloriesBurnedFromSteps = steps * caloriesPerStep
     
     // Grabbing the necessary values and assigning it to a variable
     self.CoolBeans = stepLog
     //print(self.CoolBeans)
     
     }
     return CoolBeans
     }
     func dataOutputMonth()->[Float]
     {
     HealthKitHelper().monthlySteps1() { stepLog, error in
     
     // Since there are 2112 steps in one mile, we will divide steps taken by 2112
     
     // Calculate the amount of calories burned per mile
     // By multiplying the user's weight by 0.57, we can get that.
     // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
     
     // Divide the number of calories that are burned per mile by number of steps to walk a mile
     // let caloriesPerStep = caloriesBurnedPerMile/2112
     
     // Calculating calories burned by multiplying the total steps to calories burned per steps
     //let totalCaloriesBurnedFromSteps = steps * caloriesPerStep
     
     // Grabbing the necessary values and assigning it to a variable
     self.CoolBeans = stepLog
     // print(self.CoolBeans)
     
     }
     return CoolBeans
     }
     override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
     
     super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
     
     // Redraw chart on rotation
     chart.setNeedsDisplay()
     
     }
     func dateFromString(date:NSDate) -> String {
     
     //format date
     var dateFormatter = NSDateFormatter()
     dateFormatter.dateFormat = "MM/dd" //format style. Browse online to get a format that fits your needs.
     var dateString = dateFormatter.stringFromDate(date)
     
     return dateString
     }
     func weekLabel() -> [String]
     {
     var output = [String]()
     var count  = -6
     while(count <= 0)
     {
     let calendar = NSCalendar.currentCalendar()
     let startDate = calendar.dateByAddingUnit(.Day, value: count, toDate: NSDate().endOf(.Day), options: [])
     output.append(dateFromString(startDate!))
     count += 1
     
     }
     return output
     }
     func monthLabel() -> [String]
     {
     var output = [String]()
     var count  = -29
     while(count <= 0)
     {
     let calendar = NSCalendar.currentCalendar()
     let startDate = calendar.dateByAddingUnit(.Day, value: count, toDate: NSDate().endOf(.Day), options: [])
     output.append(dateFromString(startDate!))
     count += 7
     
     }
     return output
     }
     */
    
}


