//
//  DetailTableViewController.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/2016.
//  Copyright (c) 2016 BetterU LLC. All rights reserved.
//

import UIKit

class DetailTableViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    
    // Passed from upstream
    var selection = ""
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Put a blue background behind the bar at the top (for formatting)
        let barBackground: UIView = UIView(frame: CGRectMake(0, 0, view.frame.width, 20.0))
        barBackground.backgroundColor = UIColor(red: 6 / 255.0, green: 101 / 255.0, blue: 191 / 255.0, alpha: 1.0)
        view.addSubview(barBackground)
        
        label.text = selection
    }
    
    // MARK: IBOutlet for Back (Custom)
    
    @IBAction func backClicked(sender: UIBarButtonItem) {
        
        // Close and return to upstream control
        dismissViewControllerAnimated(true, completion: nil)
    }
}

