//
//  StepsTableViewCell.swift
//  BetterU
//
//  Created by Hung Vu on 4/2/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class StepsTableViewCell: UITableViewCell {

    @IBOutlet var thumbnailImage: UIImageView!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var metricLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
