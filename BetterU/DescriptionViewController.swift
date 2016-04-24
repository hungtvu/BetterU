//
//  DescriptionViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/20/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class DescriptionViewController: UIViewController {

    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var instructionsTextView: UITextView!
    
    var categoryName = ""
    var equipmentName = ""
    var instructions = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        instructions = instructions.stringByReplacingOccurrencesOfString("<p>", withString: "")
        instructions = instructions.stringByReplacingOccurrencesOfString("</p>", withString: "")
        instructions = instructions.stringByReplacingOccurrencesOfString("<em>", withString: "")
        instructions = instructions.stringByReplacingOccurrencesOfString("</em>", withString: "")
        
        categoryNameLabel.text! = categoryName
        equipmentNameLabel.text! = equipmentName
        instructionsTextView.text! = instructions
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
