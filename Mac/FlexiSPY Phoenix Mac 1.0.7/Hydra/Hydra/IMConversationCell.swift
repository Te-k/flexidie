//
//  IMConversationCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class IMConversationCell: UITableViewCell {
    
    var conversation: IMConversation?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI() {
        nameLabel.text = conversation?.conversationName
        iconImage.setImage(imServiceName: conversation?.imV5Service ?? "")
    }

}
