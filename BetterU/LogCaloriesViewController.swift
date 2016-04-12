//
//  LogCaloriesViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/11/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class LogCaloriesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var usdaApiKey = "4niv8KdOlh2eILltqqldVhCoNsw62qKN6NiRPSo4"
        var usdaApiUrlForFoodItems = "http://api.nal.usda.gov/ndb/search/?format=json&q=banana&sort=n&max=55&offset=0&api_key=\(usdaApiKey)"
        
        var usdaApiUrlForFoodStats = "http://api.nal.usda.gov/ndb/reports/?ndbno=03167&type=s&format=json&api_key=\(usdaApiKey)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
