//
//  MealPlanViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/5/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class MealPlanViewController: UIViewController {

    @IBOutlet var foodTableView: UITableView!
    @IBOutlet var logCaloriesButton: UIButton!
    @IBOutlet var recommendFoodButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adding in rounded corners to the buttons
        logCaloriesButton.layer.cornerRadius = 8;
        recommendFoodButton.layer.cornerRadius = 8;
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
