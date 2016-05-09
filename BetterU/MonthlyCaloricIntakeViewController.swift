//
//  MonthlyCaloricIntakeViewController.swift
//  BetterU
//
//  Created by Allan Chua on 5/1/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import Foundation
import KDCircularProgress
import SwiftChart
import UIKit
import HealthKit

class MonthlyCaloricIntakeViewController: UIViewController, ChartDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var progress: KDCircularProgress!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var circleLabel: UILabel!
    //@IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    private var labelLeadingMarginInitialConstant: CGFloat!
    
    //let cellIdentifier = "WeeklyWeightCell"
    
    var calsIn: Float = 0
    var calsOut: Float = 0
    
    var selectedChart = 0
    
    var CoolBeans = [Float]()
    var CoolBeans2 = [Float]()
    
    var userId = 0
    var sumCalories: Float = 0
    
    var targetCalories: Double = 0
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewWillAppear(animated: Bool) {
        
        //dataOutputWeek()
        //print(weekLabel())
        //  HealthKitHelper().weeklySteps1()
        //labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        NSThread.sleepForTimeInterval(0.05)
        super.viewDidLoad()
        
        // Draw the chart selected from the TableViewController
        
        chart.delegate = self
        
        // Simple chart
        let series = ChartSeries(CoolBeans)     //CaloriesIn
        let series2 = ChartSeries(CoolBeans2)   //CaloriesOut
        
        series.color = ChartColors.greenColor()
        series2.color = ChartColors.orangeColor()
        
        series.area = true  //Shading
        series2.area = true
        
        chart.addSeries(series)
        chart.addSeries(series2)
        
        let labels: Array<Float> = [0,6.5,14,21.5]
        chart.xLabels = labels
        chart.labelFont = UIFont.systemFontOfSize(12)
        chart.xLabelsTextAlignment = .Center
        let labelsAsString = ["Week 1", "Week 2", "Week 3", "Week 4"]
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            
            return labelsAsString[labelIndex]
            
        }
        
        init_progress_bar()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Caloric Intake"
        
        userId = applicationDelegate.userAccountInfo["id"] as! Int
        
        dataOutputMonth()
        NSThread.sleepForTimeInterval(0.05)
        
        parseJSONForCaloriesIn()
        parseJSONForTargetCalories()
        //init_progress_bar()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func init_progress_bar(){
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.7
        progress.clockwise = true
        //progress.center = CGPoint(x: 200,y: 450)
        //let percent = UILabel(frame: CGRect(x: 5, y: 475, width: 414, height: 200))
        let percentShort = UILabel(frame: CGRect(x: 150, y: 500, width: 100, height:200))
        percentShort.center = progress.center
        //percent.center.x = progress.center.x
        percentShort.textAlignment = NSTextAlignment.Center
        //percent.textAlignment =  NSTextAlignment.Center
        percentShort.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
        //percent.font = UIFont(name:"HelveticaNeue", size: 16.0)
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .Forward
        progress.angle = 300
        
        let percentageCompleted = calculatePercentageCompleted() * 100
        let monthlySumCalories:Double = Double(sumCalories)
        percentShort.text = String(Int(monthlySumCalories)) + " / " + String(Int(targetCalories * 30))
        
        let calculatedAngle = (percentageCompleted/100) * 360
        let calDifference = abs(targetCalories * 30 - monthlySumCalories)
        //If over 100%, then make graph red
        if(percentageCompleted > 100){
            progress.setColors(UIColor.redColor(), UIColor.whiteColor(), UIColor.redColor())
            circleLabel.text = String(Int(calDifference)) + " calories over your monthly target"
            
        } else{
            progress.setColors(UIColor.greenColor(), UIColor.whiteColor(), UIColor.greenColor())
            circleLabel.text = String(Int(calDifference)) + " calories under your monthly target"
        }

        //percent.text = "You are " + String(Int(percentageCompleted)) + "% away from your goal weight!"
        //view.addSubview(progress)
        //view.addSubview(percent)
        //view.addSubview(percentShort)
        progress.animateFromAngle(0, toAngle: calculatedAngle, duration: 3) { completed in
            if completed {
                
                print("animation stopped, completed")
                self.view.addSubview(percentShort)
                //self.view.addSubview(percent)
            } else {
                print("animation stopped, was interrupted")
            }
        }
    }
    
    func calculatePercentageCompleted()->Double{
        // if(goalWeight > currentWeight){
        //   return currentWeight/goalWeight
        // }
        
        let monthlySumCalories:Double = Double(sumCalories)
        
        if targetCalories == 0
        {
            targetCalories = 1800
        }

        return monthlySumCalories / (targetCalories * 30)
    }

    // This method calls from BetterU's REST API and parses its JSON information.
    func parseJSONForTargetCalories()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/"
        
        // Convert URL to NSURL
        let url = NSURL(string: restApiUrl)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError
        {
            print("Error in retrieving JSON data: \(error.localizedDescription)")
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
                // Grabs all of the JSON data info as an array. NOTE, this stores ALL of the info, it does NOT have
                // any info from inside of the JSON.
                
                /* {
                 DCSkipped = 1;
                 WCSkipped = 1;
                 activityGoal = "Very Active";
                 activityLevel = 0;
                 age = 20;
                 bmr = 1724;
                 dailyChallengeIndex = 4;
                 email = "jdoe@vt.edu";
                 firstName = John;
                 gender = M;
                 goalType = 4;
                 goalWeight = 130;
                 height = 65;
                 id = 1;
                 lastName = Doe;
                 password = password;
                 points = 0;
                 securityAnswer = Virginia;
                 securityQuestion = 3;
                 units = I;
                 username = jdoe;
                 weeklyChallengeIndex = 2;
                 weight = 155;
                 },
                 */
                let jsonDataArray = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                
                var jsonDataDictInfo: NSDictionary = NSDictionary()
                
                var i = 0
                
                while (i < jsonDataArray.count)
                {
                    jsonDataDictInfo = jsonDataArray[i] as! NSDictionary
                    
                    if(userId == (jsonDataDictInfo["id"] as! Int) ){
                        if(jsonDataDictInfo["targetCalories"] != nil){
                            
                            // Grabs data from the JSON and stores it into the appropriate variable
                            targetCalories = jsonDataDictInfo["targetCalories"] as! Double
                            //print(targetCalories)
                            break
                        }
                    }
                    
                    i += 1
                }

            }catch let error as NSError
            {
                print("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
        }
            
        else
        {
            print("Error in retrieving JSON data!")
        }
    }
    
    func parseJSONForCaloriesIn(){
        
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress"
        
        // Convert URL to NSURL
        let url = NSURL(string: restApiUrl)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError
        {
            print("Error in retrieving JSON data: \(error.localizedDescription)")
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
                // Grabs all of the JSON data info as an array. NOTE, this stores ALL of the info, it does NOT have
                // any info from inside of the JSON.
                
                let jsonDataArray = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                
                var jsonDataDictInfo: NSDictionary = NSDictionary()
                
                var i = 0
                var foundCount = 0
                var calsInArray = [Float]()
                var calsOutArray = [Float]()
                
                while (foundCount < 30)
                    //while (i < jsonDataArray.count)
                {
                    jsonDataDictInfo = jsonDataArray[i] as! NSDictionary
                    
                    // Grabs data from the JSON and stores it into the appropriate variable
                    
                    if(userId == (jsonDataDictInfo["userId"] as! Int) ){
                        
                        calsIn = (Float)(jsonDataDictInfo["caloriesIn"] as! Double)
                        calsOut = (Float)(jsonDataDictInfo["caloriesOut"] as! Double)
                        
                        calsInArray.append(calsIn)
                        calsOutArray.append(calsOut)
                        
                        sumCalories += calsIn
                        foundCount += 1
                        
                    }
                    
                    i += 1
                    
                    if(i == jsonDataArray.count - 1){
                        break
                    }
                }
                
                CoolBeans = calsInArray
                CoolBeans2 = calsOutArray
                
            }catch let error as NSError
            {
                print("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
        }
            
        else
        {
            print("Error in retrieving JSON data!")
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: WeeklyWeightTableViewCell = tableView.dequeueReusableCellWithIdentifier("WeeklyWeightCell") as! WeeklyWeightTableViewCell
        return cell
    }
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat){
        for (seriesIndex, dataIndex) in indexes.enumerate() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                //print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
                let numberFormatter = NSNumberFormatter()
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 0
                
                let calsIn = chart.valueForSeries(0, atIndex: dataIndex)
                let calsOut = chart.valueForSeries(1, atIndex: dataIndex)
                
                let difference = calsIn! - calsOut!
                
                if(difference < 0){
                    label.text = numberFormatter.stringFromNumber(Int(abs(difference)))! + " calories lost"
                }
                    
                else{
                    label.text = numberFormatter.stringFromNumber(Int(abs(difference)))! + " calories gained"
                }
                
                // Align the label to the touch left position, centered
                //var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
                
                // Avoid placing the label on the left of the chart
                //if constant < labelLeadingMarginInitialConstant {
                //    constant = labelLeadingMarginInitialConstant
                //}
                
                // Avoid placing the label on the right of the chart
                //   let rightMargin = chart.frame.width - label.frame.width
                //   if constant > rightMargin {
                //        constant = rightMargin
                //    }
                
                //labelLeadingMarginConstraint.constant = constant
                
            }
        }
        
    }
    
    func didFinishTouchingChart(chart: Chart){
        label.text = ""
        //labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
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
        //print("dataOutputWeek")
        //print(CoolBeans)
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
    
}




