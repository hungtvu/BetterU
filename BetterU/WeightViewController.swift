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
    
    // This method gets called first when the view is shown
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Weight"
        
        init_graph()
        
        init_progress_bar()
        
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
        let percent = UILabel(frame: CGRect(x: 150, y: 500, width: 100, height: 200))
        percent.text = "You are 50% away from your goal weight!"
        //percent.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .Forward
        progress.angle = 300
        progress.setColors(UIColor.cyanColor() ,UIColor.whiteColor(), UIColor.magentaColor())
        view.addSubview(progress)
        view.addSubview(percent)
        progress.animateFromAngle(0, toAngle: 180, duration: 5) { completed in
            if completed {
                print("animation stopped, completed")
            } else {
                print("animation stopped, was interrupted")
            }
        }
    }
    
    // Chart delegate
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        // Do something on touch
    }
    
    func didFinishTouchingChart(chart: Chart) {
        // Do something when finished
    }
}

