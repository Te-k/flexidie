//
//  LicenseCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class LicenseCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
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
