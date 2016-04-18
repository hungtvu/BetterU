//
//  YearlyWeightViewController.swift
//  BetterU
//
//  Created by Mukund Katti on 4/18/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import SwiftChart
import Foundation
import KDCircularProgress

class YearlyWeightViewController: UIViewController, ChartDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var progress: KDCircularProgress!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: YearlyWeightTableViewCell = tableView.dequeueReusableCellWithIdentifier("YearlyWeightCell") as! YearlyWeightTableViewCell
        return cell
    }
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat){
        
    }
    
    func didFinishTouchingChart(chart: Chart){
        
    }
    
}