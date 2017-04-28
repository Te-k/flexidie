//
//  SMSCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/19/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class SMSCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
