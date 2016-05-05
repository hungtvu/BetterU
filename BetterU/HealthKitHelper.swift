//
//  HealthKitHelper.swift
//  BetterU
//
//  Created by Hung Vu on 4/1/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import Foundation
import HealthKit
import SwiftDate


class HealthKitHelper
{
    // This is the core of the health kit access. We can create a class reference to the health kit store
    let healthKitStore = HKHealthStore()
    
    init()
    {
        checkAuthorization()
    }
    
    // The checkAuthorization() method allows the user to check if they want us grab the health kit info
    func checkAuthorization() -> Bool
    {
        // Default for authorization
        var isEnabled = true
        
        // Check if we have access to the health kit on this device
        if HKHealthStore.isHealthDataAvailable()
        {
            // If it is, then we have to request each data manually
            // This data is used to grab the steps info from the health kit
            let steps = NSSet(object: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
            
            // After everything, we can now request access
            healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: steps as? Set<HKObjectType>) { (success, error) -> Void in
                isEnabled = success
            }
            
        }
            
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    // This method fetches daily step counts from health kit
    func recentSteps(completion: (Double, NSError?) -> ())
    {
        
        
        // The type of data we are getting
        let stepCountType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        let calendar = NSCalendar.currentCalendar()
        let startDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])
        
        // The search predicate which will fetch data from now until a day ago
        // This will be changed depending on how many days the user wants to see
        let searchPredicate = HKQuery.predicateForSamplesWithStartDate(startDate!, endDate: NSDate(), options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKSampleQuery(sampleType: stepCountType!, predicate: searchPredicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    // If we want the daily average steps, then we must do += instead of =
                    steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    
                    
                }
            }
            
            completion(steps, error)
            // print("u fukin wot m8" + String(steps))
            
        }
        
        healthKitStore.executeQuery(query)
        
    }
    func intervalMonth(daysToSub:Int, completion: (Double, NSError?) -> ())
    {
        var stepArray = [Double]()
        var count = 0
        var daySub = daysToSub
        while count < 8 {
            
            
            // The type of data we are getting
            let stepCountType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            
            let calendar = NSCalendar.currentCalendar()
            let end = calendar.dateByAddingUnit(.Day, value: daySub + 6, toDate: NSDate(), options: [])
            let startDate = calendar.dateByAddingUnit(.Day, value: daySub, toDate: NSDate(), options: [])
            
            // The search predicate which will fetch data from now until a day ago
            // This will be changed depending on how many days the user wants to see
            let searchPredicate = HKQuery.predicateForSamplesWithStartDate(startDate!, endDate: end, options: .None)
            
            // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
            let query = HKSampleQuery(sampleType: stepCountType!, predicate: searchPredicate, limit: 0, sortDescriptors: nil) { query, results, error in
                var steps: Double = 0
                
                if results?.count > 0
                {
                    for result in results as! [HKQuantitySample]
                    {
                        // If we want the daily average steps, then we must do += instead of =
                        steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                        
                        
                    }
                    stepArray.append(steps)
                }
                
                completion(steps, error)
                // print("u fukin wot m8" + String(steps))
                
            }
            
            healthKitStore.executeQuery(query)
            count+=1
            daySub += 7
        }
        //count += 1
        
    }
    func recentSteps1(completion: ([Float], NSError?) -> ())
    {
        
        
        // The type of data we are getting
        let stepCountType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        var stepLog = [Float]()
        let calendar = NSCalendar.currentCalendar()
        let startDate = calendar.dateByAddingUnit(.Day, value: -1, toDate:NSDate().endOf(.Day), options: [])
        
        // The search predicate which will fetch data from now until a day ago
        // This will be changed depending on how many days the user wants to see
        let searchPredicate = HKQuery.predicateForSamplesWithStartDate(startDate!, endDate: NSDate().endOf(.Day), options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKSampleQuery(sampleType: stepCountType!, predicate: searchPredicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    // If we want the daily average steps, then we must do += instead of =
                    steps = result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    stepLog.append(Float(steps))
                    
                }
            }
            
            completion(stepLog, error)
            // print("u fukin wot m8" + String(steps))
            
        }
        
        healthKitStore.executeQuery(query)
        
    }
    
    func dailySteps1(completion: ([Float], NSError?) -> ())
    {
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        //  let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //  let date: NSDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var stepLog = [Float]()
        
        // let startDate = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: date, options: NSCalendarOptions())!
        let startDate1 = calendar.dateByAddingUnit(.Day, value: -7, toDate: NSDate().endOf(.Day), options: [])
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate1, endDate: NSDate().endOf(.Day), options: .StrictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate().endOf(.Day), intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            
            let endDate = NSDate().endOf(.Day)
            // let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = NSCalendar.currentCalendar()
            //   let date = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: NSDate(), options: NSCalendarOptions())!
            let startDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: NSDate().endOf(.Day), options: [])
            if let myResults = results{
                myResults.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        //let date = statistics.startDate
                        let steps = quantity.doubleValueForUnit(HKUnit.countUnit())
                        stepLog.append(Float(steps))
                        //print("\(date): steps = \(steps)")
                    }
                }
            }
            completion(stepLog, error)
        }
        
        healthKitStore.executeQuery(query)
        
    }
    func weeklySteps1(completion: ([Float], NSError?) -> ())
    {
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        //  let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //  let date: NSDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var stepLog = [Float]()
        
        // let startDate = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: date, options: NSCalendarOptions())!
        let startDate1 = calendar.dateByAddingUnit(.Day, value: -7, toDate: NSDate().endOf(.Day), options: [])
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate1, endDate: NSDate().endOf(.Day), options: .StrictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate().endOf(.Day), intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            
            let endDate = NSDate().endOf(.Day)
            // let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = NSCalendar.currentCalendar()
            //   let date = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: NSDate(), options: NSCalendarOptions())!
            let startDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: NSDate().endOf(.Day), options: [])
            if let myResults = results{
                myResults.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        //let date = statistics.startDate
                        let steps = quantity.doubleValueForUnit(HKUnit.countUnit())
                        stepLog.append(Float(steps))
                        //print("\(date): steps = \(steps)")
                    }
                }
            }
            completion(stepLog, error)
        }
        
        healthKitStore.executeQuery(query)
        
    }
    func monthlySteps1(completion: ([Float], NSError?) -> ())
    {
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        //  let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //  let date: NSDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var stepLog = [Float]()
        
        // let startDate = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: date, options: NSCalendarOptions())!
        let startDate1 = calendar.dateByAddingUnit(.Day, value: -30, toDate: NSDate().endOf(.Day), options: [])
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate1, endDate: NSDate().endOf(.Day), options: .StrictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate().endOf(.Day), intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            
            let endDate = NSDate().endOf(.Day)
            // let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = NSCalendar.currentCalendar()
            //   let date = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: NSDate(), options: NSCalendarOptions())!
            let startDate = calendar.dateByAddingUnit(.Day, value: -30, toDate: NSDate().endOf(.Day), options: [])
            if let myResults = results{
                myResults.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        //let date = statistics.startDate
                        let steps = quantity.doubleValueForUnit(HKUnit.countUnit())
                        stepLog.append(Float(steps))
                        //print("\(date): steps = \(steps)")
                    }
                }
            }
            completion(stepLog, error)
        }
        
        healthKitStore.executeQuery(query)
        
    }
    func monthlySteps2(completion: ([Float], NSError?) -> ())
    {
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        //  let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //  let date: NSDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var stepLog = [Float]()
        
        // let startDate = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: date, options: NSCalendarOptions())!
        let startDate1 = calendar.dateByAddingUnit(.Day, value: -120, toDate: NSDate().endOf(.Month), options: [])
        
        let interval = NSDateComponents()
        interval.day = 7
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate1, endDate: NSDate().endOf(.Month), options: .StrictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate().endOf(.Day), intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            
            let endDate = NSDate().endOf(.Month)
            // let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = NSCalendar.currentCalendar()
            //   let date = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: NSDate(), options: NSCalendarOptions())!
            let startDate = calendar.dateByAddingUnit(.Day, value: -120, toDate: NSDate().endOf(.Month), options: [])
            if let myResults = results{
                myResults.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        //let date = statistics.startDate
                        let steps = quantity.doubleValueForUnit(HKUnit.countUnit())
                        stepLog.append(Float(steps))
                        print(stepLog.count)
                        //print("\(date): steps = \(steps)")
                    }
                }
            }
            completion(stepLog, error)
        }
        
        healthKitStore.executeQuery(query)
        
    }
    func monthlySteps3(completion: ([Float], NSError?) -> ())
    {
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        //  let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //  let date: NSDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var stepLog = [Float]()
        
        // let startDate = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: date, options: NSCalendarOptions())!
        let startDate1 = calendar.dateByAddingUnit(.Day, value: -120, toDate: NSDate().endOf(.Month), options: [])
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate1, endDate: NSDate().endOf(.Month), options: .StrictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate().endOf(.Day), intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            
            let endDate = NSDate().endOf(.Month)
            // let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = NSCalendar.currentCalendar()
            //   let date = calendarMid.dateBySettingHour(0,minute: 0,second: 0,ofDate: NSDate(), options: NSCalendarOptions())!
            let startDate = calendar.dateByAddingUnit(.Day, value: -120, toDate: NSDate().endOf(.Month), options: [])
            if let myResults = results{
                myResults.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        //let date = statistics.startDate
                        let steps = quantity.doubleValueForUnit(HKUnit.countUnit())
                        stepLog.append(Float(steps))
                        print(stepLog.count)
                        //print("\(date): steps = \(steps)")
                    }
                }
            }
            completion(stepLog, error)
        }
        
        healthKitStore.executeQuery(query)
        
    }
    
    func weeklySteps(completion: ([Float], NSError?) -> ())
        
    {
        let stepCountType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        var n = -7
        var stepLog = [Float]()
        var dateCheck = [String]()
        while n < 0
        {
            let calendar = NSCalendar.currentCalendar()
            // let calendarGreg =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let date: NSDate = NSDate()
            let calendarMid: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let newDate: NSDate = calendarMid.dateBySettingHour(23,minute: 59,second: 59,ofDate: date, options: NSCalendarOptions())!
            let startDate = calendar.dateByAddingUnit(.Day, value: n, toDate: newDate, options: [])
            let endDate = calendar.dateByAddingUnit(.Day, value: n+1, toDate: newDate, options: [])
            //print(String(startDate) + "Start")
            //print(String(endDate) + "End")
            dateCheck.append(String(startDate) + ", ")
            
            let searchPredicate = HKQuery.predicateForSamplesWithStartDate(startDate!, endDate:endDate, options: .None)
            // print(String(searchPredicate))
            let sortDesc = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(sampleType: stepCountType!, predicate: searchPredicate, limit: 0, sortDescriptors: [sortDesc]) { query, results, error in
                var steps: Float = 0.0
                // print(String(query))
                
                if results?.count > 0
                {
                    for result in results as! [HKQuantitySample]
                    {
                        // If we want the daily average steps, then we must do += instead of =
                        steps += Float(result.quantity.doubleValueForUnit(HKUnit.countUnit()))
                        //print(steps)
                    }
                    stepLog.append(steps)
                    //print(steps)
                    
                }
                completion(stepLog, error)
                
            }
            
            healthKitStore.executeQuery(query)
            n += 1
        }
        // print(dateCheckz
    }
}

////
////  HealthKitHelper.swift
////  BetterU
////
////  Created by Hung Vu on 4/1/16.
////  Copyright © 2016 BetterU LLC. All rights reserved.
////
//
//import Foundation
//import HealthKit
//
//class HealthKitHelper
//{
//    // This is the core of the health kit access. We can create a class reference to the health kit store
//    let healthKitStore = HKHealthStore()
//
//    init()
//    {
//        checkAuthorization()
//    }
//
//    // The checkAuthorization() method allows the user to check if they want us grab the health kit info
//    func checkAuthorization() -> Bool
//    {
//        // Default for authorization
//        var isEnabled = true
//
//        // Check if we have access to the health kit on this device
//        if HKHealthStore.isHealthDataAvailable()
//        {
//            // If it is, then we have to request each data manually
//            // This data is used to grab the steps info from the health kit
//            let steps = NSSet(object: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
//
//            // After everything, we can now request access
//            healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: steps as? Set<HKObjectType>) { (success, error) -> Void in
//                isEnabled = success
//            }
//
//        }
//
//        else
//        {
//            isEnabled = false
//        }
//
//        return isEnabled
//    }
//
//    // This method fetches daily step counts from health kit
//    func recentSteps(completion: (Double, NSError?) -> ())
//    {
//
//        // The type of data we are getting
//        let stepCountType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
//
//        let calendar = NSCalendar.currentCalendar()
//        let startDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])
//
//        // The search predicate which will fetch data from now until a day ago
//        // This will be changed depending on how many days the user wants to see
//        let searchPredicate = HKQuery.predicateForSamplesWithStartDate(startDate!, endDate: NSDate(), options: .None)
//
//        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
//        let query = HKSampleQuery(sampleType: stepCountType!, predicate: searchPredicate, limit: 0, sortDescriptors: nil) { query, results, error in
//            var steps: Double = 0
//
//            if results?.count > 0
//            {
//                for result in results as! [HKQuantitySample]
//                {
//                    // If we want the daily average steps, then we must do += instead of =
//                    steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
//
//                }
//            }
//
//            completion(steps, error)
//        }
//        
//        healthKitStore.executeQuery(query)
//        
//    }
//
//}
