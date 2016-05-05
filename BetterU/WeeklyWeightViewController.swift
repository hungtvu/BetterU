//
//  WeeklyWeightViewController.swift
//  BetterU
//
//  Created by Mukund Katti on 4/18/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import Foundation
import SwiftChart
import UIKit
import YLProgressBar


class WeeklyWeightViewController: UIViewController, ChartDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chart: Chart!
    
    @IBOutlet var progress: YLProgressBar!
    
    
    @IBOutlet var progressLabel: UILabel!
    
    var userId = 0
    
    let cellIdentifier = "WeeklyWeightCell"
    var username: String = ""
    var goalWeight: Double = 0
    var currentWeight: Double = 0
    var caloriesIn = [Int]()
    var caloriesOut: Int? = nil
    var targetCalories: Int? = nil
    var date: String? = nil
    var weeklySteps = [Float]()
    var weeklyWeight = [Float]()
    var weeklyCaloriesBurned = [Float]()
    var weeklyCaloriesConsumed = [Float]()
    private var labelLeadingMarginInitialConstant: CGFloat!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var labelLeadingMarginConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var movingLabel: UILabel!
    
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        computeWeeklySteps()
        NSThread.sleepForTimeInterval(0.05)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Weight"
        username = applicationDelegate.userAccountInfo.valueForKey("Username") as! String
        userId = applicationDelegate.userAccountInfo["id"] as! Int
        computeWeeklySteps()
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        NSThread.sleepForTimeInterval(0.05)
        super.viewDidLoad()
        currentWeight = Double(applicationDelegate.userAccountInfo.valueForKey("User Weight") as! NSNumber)
        parseJSONForWeight()
        parseProgressTable()
        
        //progress.setProgress(0, animated: true)
        
        computeCaloriesBurned()
        computeWeeklyWeight()
        
        init_progress_bar()
        
        //init chart
        chart.delegate = self
        let series = ChartSeries(weeklyWeight)
        series.area = true
        chart.addSeries(series)
        
        series.color = ChartColors.redColor()
        
        let labelsAsString = weekLabel()
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return labelsAsString[labelIndex]
        }
        
    }
    
    
    
    func init_progress_bar(){
        
        progress.type = YLProgressBarType.Rounded
        progress.progressTintColor  = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
        progress.stripesOrientation = YLProgressBarStripesOrientation.Vertical
        progress.stripesDirection   = YLProgressBarStripesDirection.Left;
        
        let percentageCompleted = calculatePercentageCompleted() * 100
        
        progress.setProgress(CGFloat(percentageCompleted/100), animated: true)
        
        let percentageNeeded = 100 - percentageCompleted
        progressLabel.text = "You are " + String(Int(percentageNeeded)) + "% away from your goal weight!"
        
    }
    
    func calculatePercentageCompleted()->Double{
        if(goalWeight > currentWeight){
            return currentWeight/goalWeight
        }
        return goalWeight/currentWeight
    }
    
    // This method calls from BetterU's REST API and parses its JSON information.
    func parseJSONForWeight()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user"
        
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
                    
                    if username == jsonDataDictInfo["username"] as! String {
                        // Grabs data from the JSON and stores it into the appropriate variable
                        targetCalories = jsonDataDictInfo["targetCalories"] as? Int
                        goalWeight = jsonDataDictInfo["goalWeight"] as! Double
                        userId = jsonDataDictInfo["id"] as! Int
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
    
    func parseProgressTable(){
        
        
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
                var j = 0
                while (i < jsonDataArray.count)
                {
                    jsonDataDictInfo = jsonDataArray[i] as! NSDictionary
                    
                    if userId == jsonDataDictInfo["userId"] as? Int
                    {
                        if caloriesIn.count == 7 {
                            break
                        }
                        // Grabs data from the JSON and stores it into the appropriate variable
                        caloriesIn.append((jsonDataDictInfo["caloriesIn"] as? Int)!)
                        j+=1
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
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyWeight.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: WeeklyWeightTableViewCell = tableView.dequeueReusableCellWithIdentifier("WeeklyWeightCell") as! WeeklyWeightTableViewCell
        
        let date = weekLabel()
        
        //let weight = weeklyWeight[indexPath.row]
        let weight = weeklyWeight[weeklyWeight.count - 1 - indexPath.row]
        //cell.date.text = date[indexPath.row]
        cell.date.text = date[date.count - 1 - indexPath.row]
        cell.weight.text = String.localizedStringWithFormat("%.2f", weight) + "lbs"
        
        return cell
    }
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat){
        for (seriesIndex, dataIndex) in indexes.enumerate() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                //print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
                let numberFormatter = NSNumberFormatter()
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 0
                movingLabel.text = String.localizedStringWithFormat("%.2f", value) + " lbs"
                
                // Align the label to the touch left position, centered
                var constant = labelLeadingMarginInitialConstant + left - (movingLabel.frame.width / 2)
                
                // Avoid placing the label on the left of the chart
                if constant < labelLeadingMarginInitialConstant {
                    constant = labelLeadingMarginInitialConstant
                }
                
                // Avoid placing the label on the right of the chart
                let rightMargin = chart.frame.width - movingLabel.frame.width
                if constant > rightMargin {
                    constant = rightMargin
                }
                
                labelLeadingMarginConstraint.constant = constant
                
            }
        }
        
        
    }
    
    func didFinishTouchingChart(chart: Chart){
        movingLabel.text = ""
        labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
        
    }
    
    func computeWeeklyWeight(){
        
        var i = 0
        var weight = self.currentWeight
        while i < weeklyCaloriesBurned.count {
            let calorieChange = Float(caloriesIn[i]) - weeklyCaloriesBurned[i]
            let poundChange = abs(calorieChange)/3500
            if calorieChange < 0 {
                weight = weight - Double(poundChange)
            }else{
                weight = weight + Double(poundChange)
            }
            weeklyWeight.append(Float(weight))
            i+=1
        }
        
        //self.currentWeight = Double(weeklyWeight[weeklyWeight.count-1])
        
    }
    
    func computeCaloriesBurned(){
        
        for stepCount in weeklySteps {
            
            let caloriesBurnedPerMile = currentWeight * 0.57
            let caloriesPerStep = caloriesBurnedPerMile/2112
            let totalCaloriesBurnedFromSteps = stepCount * Float(caloriesPerStep)
            weeklyCaloriesBurned.append(totalCaloriesBurnedFromSteps)
            
        }
        
    }
    
    
    func computeWeeklySteps()->[Float]
    {
        HealthKitHelper().weeklySteps1() { stepLog, error in
            
            // Grabbing the necessary values and assigning it to a variable
            self.weeklySteps = stepLog
            
        }
        return weeklySteps
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
    
    func dateFromString(date:NSDate) -> String {
        
        //format date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd" //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
    
}