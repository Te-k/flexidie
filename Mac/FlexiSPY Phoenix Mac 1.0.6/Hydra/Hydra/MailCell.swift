//
//  MailCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/21/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class MailCell: UITableViewCell {

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
