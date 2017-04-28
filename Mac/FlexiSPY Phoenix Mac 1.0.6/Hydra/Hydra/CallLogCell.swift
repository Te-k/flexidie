//
//  CallLogCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class CallLogCell: UITableViewCell {
    
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var callDirectionImageView: UIImageView!
    @IBOutlet weak var infoButton: InfoButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
