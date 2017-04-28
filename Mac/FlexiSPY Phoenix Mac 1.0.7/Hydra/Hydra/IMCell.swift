//
//  IMCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

protocol IMCellDelegate {
    func imCellDidTapImage(imageUrl: String)
    func imCellDidTapLabel(location: IMLocation)
}

class IMCell: UITableViewCell {
    
    var instantMessage: IM?
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var attachedImage: UIImageView!
    var delegate: IMCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
//        let string: NSString = messageLabel.text! as NSString
//        
//        var attribute = [String: Any]()
//        attribute["sizeWithFont"] = messageLabel.font
//        attribute["constrainedToSize"] = 180
//        attribute["lineBreakMode"] = messageLabel.lineBreakMode
//        
//        let expectedSize = string.size(attributes: attribute)
//        let dif = messageLabel.frame.size.width - expectedSize.width
//        messageLabel.frame.size.width = expectedSize.width
//        messageLabel.frame.origin.x += dif
    }
    
    func updateUI() {
        if let imageUrl = URL(string: instantMessage?.sender?.profileImageUrl ?? "") {
            profileImage.setImage(url: imageUrl)
        }
        
        messageLabel.preferredMaxLayoutWidth = 180
        if let charactorCount = instantMessage?.message?.characters.count,
            charactorCount > 0
            {
            messageLabel.text = instantMessage?.message
        } else {
            messageLabel.text = " "
        }
    
        datetimeLabel.text = instantMessage?.userTime?.formattedDateTimeString(toFormat: .dateTimeSMSCell)
        
        if  instantMessage?.canDisplayThumbnail == true ,
            let thumbnailUrl = instantMessage?.thumbailImageUrl ,
            let imageUrl = URL(string: thumbnailUrl) ,
            attachedImage != nil {
                attachedImage.setImage(url: imageUrl)
            
            if instantMessage?.canShowMoreDetail == true {
                let tabGesture = UITapGestureRecognizer(target: self, action: #selector(IMCell.attachImageTapped(sender:)))
                attachedImage.gestureRecognizers = [tabGesture]
            }
        }
        
        if instantMessage?.hasShareLocation == true {
            messageLabel.addImage(imageName: "flag")
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(IMCell.messageLabelTapped(sender:)))
            messageLabel.isUserInteractionEnabled = true
            messageLabel.gestureRecognizers = [tabGesture]
        }
    }
    
    func messageLabelTapped(sender: UILabel) {
        if let location = instantMessage?.location {
            delegate?.imCellDidTapLabel(location: location)
        }
    }
    
    func attachImageTapped(sender: UIImageView) {
        if let images = instantMessage?.attachments  {
            delegate?.imCellDidTapImage(imageUrl: images.first?.attachmentURL ?? "")
        }
    }
}
