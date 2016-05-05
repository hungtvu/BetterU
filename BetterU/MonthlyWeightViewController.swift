//
//  MonthlyWeightViewController.swift
//  BetterU
//
//  Created by Mukund Katti on 4/18/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import Foundation
import SwiftChart
import UIKit
import YLProgressBar
import Alamofire
import SwiftyJSON


class MonthlyWeightViewController: UIViewController, ChartDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var chart: Chart!
    
    @IBOutlet var progress: YLProgressBar!
    
    @IBOutlet var percentLabel: UILabel!
    
    @IBOutlet var labelLeadingMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var movingLabel: UILabel!
    private var labelLeadingMarginInitialConstant: CGFloat!
    
    var username: String = ""
    var userId: Int = 0
    var monthlySteps = [Float]()
    var monthlyCaloriesBurned = [Float]()
    var monthlyWeight = [Float]()
    var targetCalories: Int? = nil
    var goalWeight: Double = 0
    var currentWeight: Double = 0
    var caloriesIn = [Int]()
    var caloriesOut = [Int]()
    var miles = [Double]()
    var steps = [Int]()
    var logDate = [Int]()
    
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Weight"
        username = applicationDelegate.userAccountInfo.valueForKey("Username") as! String
        dataOutputMonth()
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        NSThread.sleepForTimeInterval(0.05)
        super.viewDidLoad()
        currentWeight = Double(applicationDelegate.userAccountInfo.valueForKey("User Weight") as! NSNumber)
        parseJSONForGoalWeight()
        parseProgressTable()
        
        computeCaloriesBurned()
        computeMonthlyWeight()
        
        init_progress_bar()
        
        postWeightToProgress()
        
        
        //init chart
        chart.delegate = self
        let series = ChartSeries(monthlyWeight)
        series.area = true
        chart.addSeries(series)
        series.color = ChartColors.redColor()
        let labels: Array<Float> = [0,6.5,14,21.5]
        chart.xLabels = labels
        chart.labelFont = UIFont.systemFontOfSize(12)
        chart.xLabelsTextAlignment = .Center
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
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlyWeight.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MonthlyWeightTableViewCell = tableView.dequeueReusableCellWithIdentifier("MonthlyWeightCell") as! MonthlyWeightTableViewCell
        
        
        let date = monthLabelTable()
        
        let weight = monthlyWeight[monthlyWeight.count - 1 - indexPath.row]
        
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
    
    func dateFromString(date:NSDate) -> String {
        
        //format date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd" //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
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
            self.monthlySteps = stepLog
            // print(self.CoolBeans)
            
        }
        return monthlySteps
    }
    
    func computeMonthlyWeight(){
        
        var i=0
        var currentWeight: Double = self.currentWeight
        while i < monthlyCaloriesBurned.count {
            
            let calorieChange = Float(caloriesIn[i]) - monthlyCaloriesBurned[i]
            let poundChange = abs(calorieChange)/3500
            if calorieChange < 0 {
                currentWeight = currentWeight - Double(poundChange)
            }else{
                currentWeight = currentWeight + Double(poundChange)
            }
            monthlyWeight.append(Float(currentWeight))
            i+=1
        }
        //self.currentWeight = Double(monthlyWeight[monthlyWeight.count-1])
    }
    
    func computeCaloriesBurned(){
        
        for stepCount in monthlySteps {
            
            let caloriesBurnedPerMile = currentWeight * 0.57
            let caloriesPerStep = caloriesBurnedPerMile/2112
            let totalCaloriesBurnedFromSteps = stepCount * Float(caloriesPerStep)
            monthlyCaloriesBurned.append(totalCaloriesBurnedFromSteps)
            
        }
        
    }
    
    // This method calls from BetterU's REST API and parses its JSON information.
    func parseJSONForGoalWeight()
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
                        if caloriesIn.count == 30 {
                            break
                        }
                        // Grabs data from the JSON and stores it into the appropriate variable
                        caloriesIn.append((jsonDataDictInfo["caloriesIn"] as? Int)!)
                        caloriesOut.append((jsonDataDictInfo["caloriesOut"] as? Int)!)
                        miles.append((jsonDataDictInfo["miles"] as? Double)!)
                        steps.append((jsonDataDictInfo["steps"] as? Int)!)
                        logDate.append((jsonDataDictInfo["logDate"] as? Int)!)
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
    
    func postWeightToProgress(){
        
        while monthlyWeight.count < logDate.count
        {
            monthlyWeight.append(monthlyWeight[monthlyWeight.count - 1])
        }
        
        if monthlyWeight.count >= logDate.count {
            
            var i = 0
            while(i < logDate.count)
            {
                
                let temp = Double(monthlyWeight[i])
                let tempRounded = round(100 * temp)/100
                
                //endpoint to database you want to post to
                let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/\(logDate[i])"
                
                //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
                //Format is = "Field": value
                let newPost = ["caloriesIn": caloriesIn[i], "caloriesOut":caloriesOut[i],"logDate":logDate[i],"miles":miles[i],"steps":steps[i],"userId":userId,"weight":tempRounded]
                
                //Creating the request to post the newPost JSON var.
                Alamofire.request(.PUT, postsEndpoint, parameters: newPost as? [String : AnyObject], encoding: .JSON)
                    .responseJSON { response in
                        guard response.result.error == nil else {
                            // got an error in getting the data, need to handle it
                            print("error calling GET on /posts/1")
                            print(response.result.error!)
                            return
                        }
                        
                        if let value: AnyObject = response.result.value {
                            // handle the results as JSON, without a bunch of nested if loops
                            // this might not return anything here, but check the DB just in case. It might post anyway
                            let post = JSON(value)
                            print("The post is: " + post.description)
                        }
                }
                
                i += 1
                
            }
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
        percentLabel.text = "You are " + String(Int(percentageNeeded)) + "% away from your goal weight!"
        
        
    }
    
    func calculatePercentageCompleted()->Double{
        if(goalWeight > currentWeight){
            return currentWeight/goalWeight
        }
        return goalWeight/currentWeight
    }
    
    func roundToPlaces(value: Double, decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return round(value * divisor) / divisor
    }
    
}