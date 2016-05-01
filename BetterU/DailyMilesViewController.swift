//
//  DailyCaloriesViewController.swift
//  BetterU
//
//  Created by Travis Lu on 4/25/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftChart
import Foundation
import SwiftDate

class DailyMilesViewController: UIViewController, ChartDelegate{
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    private var labelLeadingMarginInitialConstant: CGFloat!
    var weightInLbs: Int = 800
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var selectedChart = 0
    
    var CoolBeans = [Float]()
    override func viewWillAppear(animated: Bool) {
        dataOutputDay()
        //print(weekLabel())
        //  HealthKitHelper().weeklySteps1()
        //print("LMAO")
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        NSThread.sleepForTimeInterval(0.05)
        super.viewDidLoad()
        
        // Draw the chart selected from the TableViewController
        
        // print(CoolBeans)
        chart.delegate = self
        //print("LMAO1")
        for var i = CoolBeans.count-1; i>=0; i -= 1
        {// print(i)
            CoolBeans[i] = (CoolBeans[i]/2112)
            //print(CoolBeans[i])
        }
        if CoolBeans.count != 0
        {
        // Simple chart
        let series = ChartSeries(CoolBeans)
        series.color = ChartColors.greenColor()
        series.area = true
        chart.addSeries(series)
        //  chart.xLabelsFormatter = "Day"
        let labels: Array<Float> = [0,Float(CoolBeans.count-1)]
        chart.xLabels = labels
        //chart.labelFont = UIFont.systemFontOfSize(12)
        //chart.xLabelsTextAlignment = .Center
        //print(monthLabel())
        let labelsAsString = ["12AM", "Now"]
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return labelsAsString[labelIndex]
        }
        }
        else{
            let labels: Array<Float> = [0]
            chart.xLabels = labels
            let labelsAsString = ["No Data!"]
            chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                return labelsAsString[labelIndex]
        }
    }
    }
    override func viewDidLoad() {
        
        
        
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerate() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                //print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
                let numberFormatter = NSNumberFormatter()
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 0
                label.text = numberFormatter.stringFromNumber(Int(value))! + " Miles"
                
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
    func dataOutputDay()->[Float]
    {
        HealthKitHelper().recentSteps1() { stepLog, error in
            
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
    
    
}