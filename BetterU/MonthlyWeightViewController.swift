//
//  MonthlyWeightViewController.swift
//  BetterU
//
//  Created by Mukund Katti on 4/18/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import Foundation
import SwiftChart
import KDCircularProgress
import UIKit


class MonthlyWeightViewController: UIViewController, ChartDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var progress: KDCircularProgress!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MonthlyWeightTableViewCell = tableView.dequeueReusableCellWithIdentifier("MonthlyWeightCell") as! MonthlyWeightTableViewCell
        return cell
    }
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat){
        
    }
    
    func didFinishTouchingChart(chart: Chart){
        
    }
    
}