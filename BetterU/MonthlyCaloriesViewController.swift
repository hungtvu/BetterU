//
//  MonthlyCaloriesViewController.swift
//  BetterU
//
//  Created by Travis Lu on 4/18/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftChart
import Foundation
import SwiftDate
import SwiftyJSON
import Alamofire

class MonthlyCaloriesViewController: UIViewController, ChartDelegate,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    private var labelLeadingMarginInitialConstant: CGFloat!
    let cellIdentifier = "CellIdentifier"
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    @IBOutlet var cellLabel: UILabel!
    var selectedChart = 0
    var weightInLbs: Int = 800
    var CoolBeans = [Float]()
    var TableArray1 = [Float]()
    var RowArray = [[Float]]()
    var SectionArray = [String]()
    var LabelArray = [String]()
    var TableArray = [Float]()
    var summedArray = [Float]()

    var TableLabelArray = [[String]]()
	    var TableStuff = [String]()
    
    var caloriesIn = [Int]()
    var caloriesOut = [Int]()
    var miles = [Double]()
    var steps = [Int]()
    var logDate = [Int]()
    var currentWeight = [Double]()
    var userId = 0
    
    
    override func viewWillAppear(animated: Bool) {
        dataOutputMonth()
        userId = applicationDelegate.userAccountInfo["id"] as! Int
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
        //print(CoolBeans.count)
        var i = CoolBeans.count-1
        //for var i = CoolBeans.count-1; i>=0; i -= 1
        while (i >= 0)
        {
            //  print(i)
            CoolBeans[i] = ((0.57 * Float(self.weightInLbs))/2112)*(CoolBeans[i])
            i = i - 1
        }
        
        let series = ChartSeries(CoolBeans)
        series.color = ChartColors.yellowColor()
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
        
        parseProgressTable()
        postCaloriesBurnedToProgress()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        weightInLbs = applicationDelegate.userAccountInfo["User Weight"] as! Int
        dataOutputMonth()
        TableArray = dataOutputMonth2()
        TableArray1 = dataOutputMonth3()
        NSThread.sleepForTimeInterval(0.1)
        prepareTableData()
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return RowArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print(CoolBeans.count)
        return RowArray[section].count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < SectionArray.count {
            return SectionArray[ section]
        }
        
        return nil
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MonthCaloriesTableViewCell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier1") as! MonthCaloriesTableViewCell
        // let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        var output = ["This Week", "1 Week ago"]
        for i in 2  ..< TableArray.count
        {
            output.append(String(i) + " Weeks ago" )
        }
        // Fetch Fruit
       	
        // print(TableArray.count - 1 - indexPath.row)
        let fruit = RowArray[indexPath.section][indexPath.row]
        
        // Configure Cell
        //cell.textLabel?.text = output[indexPath.row]
        cell.dateLabel?.text = TableLabelArray[indexPath.section][indexPath.row]
        cell.stepsLabel?.text = String(Int(fruit)) + " Calories"
        
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
                label.text = numberFormatter.stringFromNumber(Int(value))! + " Calories"
                
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
                while (i < jsonDataArray.count)
                {
                    jsonDataDictInfo = jsonDataArray[i] as! NSDictionary
                    
                    if userId == jsonDataDictInfo["userId"] as? Int
                    {
                        // Grabs data from the JSON and stores it into the appropriate variable
                        caloriesIn.append((jsonDataDictInfo["caloriesIn"] as? Int)!)
                        caloriesOut.append((jsonDataDictInfo["caloriesOut"] as? Int)!)
                        miles.append((jsonDataDictInfo["miles"] as? Double)!)
                        steps.append((jsonDataDictInfo["steps"] as? Int)!)
                        logDate.append((jsonDataDictInfo["logDate"] as? Int)!)
                        currentWeight.append(jsonDataDictInfo["weight"] as! Double)
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

    
    func postCaloriesBurnedToProgress(){
        
        var caloriesOutArray = [Int]()
        
        if RowArray.count > 0 {
        var i = 0
            while (i < 5)
            {
                var j = 0
                while (j < RowArray[i].count)
                {
                    caloriesOutArray.append(Int(RowArray[i][j]))
                    j = j + 1
                }
                
                i = i + 1
                
            }
        }
        caloriesOutArray = caloriesOutArray.reverse()
        
        while (caloriesOutArray.count < logDate.count)
        {
            caloriesOutArray.append(caloriesOutArray[caloriesOutArray.count - 1])
        }
        
        var i = logDate.count - 1
        while(i >= 0)
        {
            
            //endpoint to database you want to post to
            let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.progress/\(userId)/\(logDate[i])"
            
            //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
            //Format is = "Field": value
            let newPost = ["caloriesIn": caloriesIn[i], "caloriesOut":caloriesOutArray[i],"logDate":logDate[i],"miles":miles[i],"steps":steps[i],"userId":userId,"weight":currentWeight[i]]
            
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
            
            i = i - 1
            
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
        var i = CoolBeans.count
        //for var i = CoolBeans.count; i<0; i -= 1
        while(i < 0)
        {
            CoolBeans[i] = (0.57 * Float(self.weightInLbs))*(CoolBeans[i]/2112)
            i = i - 1
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
        var i = CoolBeans.count-1
        //for var i = CoolBeans.count-1; i>=0; i -= 1
        while (i >= 0)
        {
            //  print(i)
            CoolBeans[i] = ((0.57 * Float(self.weightInLbs))/2112)*(CoolBeans[i])
            i = i - 1
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
        var i = CoolBeans.count
        //for var i = CoolBeans.count; i<0; i -= 1
        while(i < 0)
        {
            CoolBeans[i] = (0.57 * Float(self.weightInLbs))*(CoolBeans[i]/2112)
            i = i - 1
        }
       // print(CoolBeans)
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
        var count  = -1 * TableArray1.count + 1
        while(count <= 0)
        {
            
            let calendar = NSCalendar.currentCalendar()
            let startDate = calendar.dateByAddingUnit(.Day, value: count, toDate: NSDate().endOf(.Day), options: [])
            output.append(dateFromString(startDate!))
            count += 1
            
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
    func prepareTableData()
    {
        var count = 0;
        var tempRowArray = [Float]()
        var tempLabelRowArray = [String]()
        LabelArray = monthLabel()
        
        for i in 0 ..< TableArray1.count
        {
            if(count < 7)
            {
                tempLabelRowArray.append(LabelArray[i])
                TableArray1[i] =  ((0.57 * Float(self.weightInLbs))/2112)*( TableArray1[i])
                tempRowArray.append(TableArray1[i])
                count += 1
            }
            else{
                count = 0;
                tempRowArray = tempRowArray.reverse()
                tempLabelRowArray = tempLabelRowArray.reverse()
                summedArray.append(tempRowArray.reduce(0, combine: {$0 + $1}))
                TableLabelArray.append(tempLabelRowArray)
                RowArray.append(tempRowArray)
                tempRowArray.removeAll()
                tempLabelRowArray.removeAll()
                tempLabelRowArray.append(LabelArray[i])
                TableArray1[i] =  ((0.57 * Float(self.weightInLbs))/2112)*( TableArray1[i])
                tempRowArray.append(TableArray1[i])
                count += 1
            }
        }
        tempRowArray = tempRowArray.reverse()
        tempLabelRowArray = tempLabelRowArray.reverse()
        summedArray.append(tempRowArray.reduce(0, combine: {$0 + $1}))
        RowArray.append(tempRowArray)
        TableLabelArray.append(tempLabelRowArray)
        TableLabelArray = TableLabelArray.reverse()
        RowArray = RowArray.reverse()
        // print(RowArray)
        
        for i in 0 ..< RowArray.count
        {
            if i == 0            {
                SectionArray.append("This Week - " + String(Int(summedArray[RowArray.count - 1 ])) + " Calories" )
            }
            if i == 1
            {
                SectionArray.append("1 Week Ago - " + String(Int(summedArray[RowArray.count - 2])) + " Calories")
            }
            else if i != 0 && i != 1 {
                SectionArray.append(String( i) + " Weeks Ago - " + String(Int(summedArray[RowArray.count - 1 - i])) + " Calories")
            }
        }
    }
    
    func dataOutputMonth2()->[Float]
    {
        HealthKitHelper().monthlySteps2() { stepLog, error in
            
            // Since there are 2112 steps in one mile, we will divide steps taken by 2112
            
            // Calculate the amount of calories burned per mile
            // By multiplying the user's weight by 0.57, we can get that.
            // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
            
            // Divide the number of calories that are burned per mile by number of steps to walk a mile
            // let caloriesPerStep = caloriesBurnedPerMile/2112
            
            // Calculating calories burned by multiplying the total steps to calories burned per steps
            //let totalCaloriesBurnedFromSteps = steps * caloriesPerStep
            
            // Grabbing the necessary values and assigning it to a variable
            self.TableArray = stepLog
            // print(self.CoolBeans)
            
        }
        // print(TableArray)
        return TableArray
    }
    func dataOutputMonth3()->[Float]
    {
        HealthKitHelper().monthlySteps3() { stepLog, error in
            
            // Since there are 2112 steps in one mile, we will divide steps taken by 2112
            
            // Calculate the amount of calories burned per mile
            // By multiplying the user's weight by 0.57, we can get that.
            // That 0.57 is based on a formula that calculates calories when a person walks a casual pace of 2 mph
            
            // Divide the number of calories that are burned per mile by number of steps to walk a mile
            // let caloriesPerStep = caloriesBurnedPerMile/2112
            
            // Calculating calories burned by multiplying the total steps to calories burned per steps
            //let totalCaloriesBurnedFromSteps = steps * caloriesPerStep
            
            // Grabbing the necessary values and assigning it to a variable
            self.TableArray1 = stepLog
            // print(self.CoolBeans)
            
        }
        // print(TableArray1)
        return TableArray1
    }
    
    
}
    