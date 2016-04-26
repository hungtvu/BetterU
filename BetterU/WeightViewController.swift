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

class WeightViewController: UIViewController {
    
    @IBOutlet var containerB: UIView!
    @IBOutlet var containerC: UIView!
    var goalWeight: Double = 0
    var currentWeight: Double = 0
    
    // This method gets called first when the view is shown
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Weight"
        
    }
    
    @IBAction func intervalChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
            
            
        case 0:
            self.containerB.alpha = 0
            self.containerC.alpha = 1
        case 1:
            self.containerB.alpha = 1
            self.containerC.alpha = 0
            
            
            
        default:
            
            break
        }
        
    }
}

