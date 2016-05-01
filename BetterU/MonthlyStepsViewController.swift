//
//  MonthlyStepsViewController.swift
//  BetterU
//
//  Created by Travis Lu on 4/9/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftChart
import Foundation
import SwiftDate

class MonthlyStepsViewController: UIViewController, ChartDelegate,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    private var labelLeadingMarginInitialConstant: CGFloat!
    let cellIdentifier = "CellIdentifier"
    var stepsCount: Int = 0
    var stepsMonth = [Int]()
    @IBOutlet var cellLabel: UILabel!
    var selectedChart = 0
    
    var CoolBeans = [Float]()
    var TableStuff = [String]()
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(),
                       {
                        
                        self.dataOutputMonth()
                        
                        
        })
        /*
       HealthKitHelper().intervalMonth(-56) { steps, error in
            
            // Since there are 2112 steps in one mile, we will divide steps taken by 2112
            //let milesFromSteps: Double = steps/2112
            
            // Calculate the amount of calories burned per mile
            // By multiplying the user's weight by 0.57, we can get that.
            // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
       //     let caloriesBurnedPerMile = 0.57 * Double(self.weightInLbs)
            
          //  // Divide the number of calories that are burned per mile by number of steps to walk a mile
            //let caloriesPerStep = caloriesBurnedPerMile/2112
            
            // Calculating calories burned by multiplying the total steps to calories burned per steps
           // let totalCaloriesBurnedFromSteps = steps * caloriesPerStep
      
            // Grabbing the necessary values and assigning it to a variable
            //self.totalCaloriesBurned = round(totalCaloriesBurnedFromSteps * 10)/10
           // self.totalMilesWalked = round(milesFromSteps * 100)/100
            print(steps)
            self.stepsCount = Int(steps)
            NSThread.sleepForTimeInterval(0.05)
            self.stepsMonth.append(Int(steps))

                        
      

            
          
 
        }
 */
       // stepsMonth.append(stepsCount)
       // print(stepsMonth)
 
        //print(weekLabel())
        //  HealthKitHelper().weeklySteps1()
       // print("LMAO")
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        NSThread.sleepForTimeInterval(0.05)
        super.viewDidLoad()
        
        // Draw the chart selected from the TableViewController
        
        // print(CoolBeans)
        chart.delegate = self
        //print("LMAO1")
        
        // Simple chart
        let series = ChartSeries(CoolBeans)
        // series.color = ChartColors.greenColor()
        series.area = true
        chart.addSeries(series)
        //  chart.xLabelsFormatter = "Day"
        let labels: Array<Float> = [0,6.5,14,21.5]
        chart.xLabels = labels
        chart.labelFont = UIFont.systemFontOfSize(12)
        chart.xLabelsTextAlignment = .Center
        //print(monthLabel())
        let labelsAsString = ["Week 1", "Week 2", "Week 3", "Week 4"]
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return labelsAsString[labelIndex]
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dataOutputMonth()
        NSThread.sleepForTimeInterval(0.05)
        
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print(CoolBeans.count)
        return CoolBeans.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MonthStepsTableViewCell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as! MonthStepsTableViewCell
        
        // let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let output = monthLabelTable()
        // Fetch Fruit
        let fruit = CoolBeans[CoolBeans.count - 1 - indexPath.row]
        
        // Configure Cell
        // cell.textLabel?.text = output[indexPath.row]
        cell.dateLabel?.text = output[output.count - 1 - indexPath.row]
        cell.stepsLabel?.text = String(Int(fruit)) + " Steps"
        // cellLabel.text = String(fruit)
        return cell
    }
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
    func dataOutputTable()->[Float]
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd" //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(date)
        
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
        
        let output = [String]()
        var count  = -29
        while(count <= 0)
        {
            /*
             let calendar = NSCalendar.currentCalendar()
             let lastWeek = calendar.dateByAddingUnit(.Day, value: count, toDate: NSDate().lastDayOfWeek(.Wee), options: [])
             let startDate = calendar.dateByAddingUnit(.Day, value: count, toDate: NSDate().endOf(.Day), options: [])
             output.append(dateFromString(startDate!))*/
            count += 7
            
        }
        return output
    }
    func monthLabelTable() -> [String]
    {
        
        var output = [String]()
        var count  = -29
        while(count <= 0)
        {
            
            let calendar = NSCalendar.currentCalendar()
            let startDate = calendar.dateByAddingUnit(.Day, value: count, toDate: NSDate().endOf(.Day), options: [])
            output.append(dateFromString(startDate!))
            count += 1
            
        }
        return output
    }
    
    
}
