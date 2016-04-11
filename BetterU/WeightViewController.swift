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
import KDCircularProgress

class WeightViewController: UIViewController, ChartDelegate {
    
    var goalWeight: Double = 0
    var currentWeight: Double = 0
    
    // This method gets called first when the view is shown
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Weight"
        
        parseJSONForGoalWeight()
        parseJSONForCurrentWeight()
        
        init_graph()
        
        init_progress_bar()
        
    }
    
    func parseJSONForCurrentWeight(){
        
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
                    
                    // Grabs data from the JSON and stores it into the appropriate variable
                    currentWeight = jsonDataDictInfo["weight"] as! Double
                    
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
                    
                    // Grabs data from the JSON and stores it into the appropriate variable
                    goalWeight = jsonDataDictInfo["goalWeight"] as! Double
                    
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

    
    
    func init_graph(){
        let chart = Chart(frame: CGRect(x: 100, y: 110, width: 360, height: 200))
        chart.delegate = self
        chart.center.x = self.view.center.x
        let data = [(x: 0, y: 0), (x: 0.5, y: 2), (x: 1.2, y: 2), (x: 2, y: 0), (x: 2, y: 1.1)]
        let series = ChartSeries(data: data)
        chart.addSeries(series)
        
        self.view.addSubview(chart)
        
    }
    
    func init_progress_bar(){
        let progress = KDCircularProgress(frame: CGRect(x: 450, y: 450, width: 200, height: 200))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.7
        progress.clockwise = true
        progress.center = CGPoint(x: 200,y: 450)
        let percent = UILabel(frame: CGRect(x: 5, y: 475, width: 414, height: 200))
        let percentShort = UILabel(frame: CGRect(x: 150, y: 500, width: 100, height:200))
        percentShort.center = progress.center
        percent.center.x = progress.center.x
        percentShort.textAlignment = NSTextAlignment.Center
        percent.textAlignment =  NSTextAlignment.Center
        percentShort.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        percent.font = UIFont(name:"HelveticaNeue", size: 16.0)
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .Forward
        progress.angle = 300
        progress.setColors(UIColor.cyanColor() ,UIColor.whiteColor(), UIColor.magentaColor())
        let percentageCompleted = calculatePercentageCompleted() * 100
        percentShort.text = String(Int(percentageCompleted)) + "%"
        let calculatedAngle = (percentageCompleted/100) * 360
        percent.text = "You are " + String(Int(percentageCompleted)) + "% away from your goal weight!"
        view.addSubview(progress)
        view.addSubview(percent)
        //view.addSubview(percentShort)
        progress.animateFromAngle(0, toAngle: calculatedAngle, duration: 5) { completed in
            if completed {
                
                print("animation stopped, completed")
                self.view.addSubview(percentShort)
                self.view.addSubview(percent)
            } else {
                print("animation stopped, was interrupted")
            }
        }
    }
    
    
    func calculatePercentageCompleted()->Double{
        if(goalWeight > currentWeight){
            return currentWeight/goalWeight
        }
        return goalWeight/currentWeight
    }
    
    
    // Chart delegate
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        // Do something on touch
    }
    
    func didFinishTouchingChart(chart: Chart) {
        // Do something when finished
    }
}

