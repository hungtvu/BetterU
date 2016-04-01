//
//  HealthKitHelper.swift
//  BetterU
//
//  Created by Hung Vu on 4/1/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import Foundation
import HealthKit

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
        }
        
        healthKitStore.executeQuery(query)
        
    }

}
