//
//  IMTextCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/27/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ChronologicalCell: UITableViewCell {
    
    var chronologicalItem: ChronologicalItem?
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateUI() {
        
        if let imageUrl = URL(string: chronologicalItem?.imageUrl ?? "") {
            thumbnailImage.setImage(url: imageUrl)
        } else {
            thumbnailImage.image = nil
        }
        
        serviceNameLabel.text = chronologicalItem?.serviceName
        messageLabel.text = chronologicalItem?.lastMessage
        dateLabel.text = chronologicalItem?.datetime?.formattedDateTimeString(toFormat: .dateWithFullName)
        timeLabel.text = chronologicalItem?.datetime?.formattedDateTimeString(toFormat: .time)
    }

}
