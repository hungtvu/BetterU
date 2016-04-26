//
//  DailyCaloriesTableViewCell.swift
//  BetterU
//
//  Created by Travis Lu on 4/25/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class DailyMilesTableViewCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel?
    //  @IBOutlet var logoImageView:    UIImageView?
    @IBOutlet var stepsLabel:  UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}