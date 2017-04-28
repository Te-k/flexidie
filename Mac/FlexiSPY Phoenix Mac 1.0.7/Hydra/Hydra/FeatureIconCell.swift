//
//  SettingCell.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/22/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class FeatureIconCell: UICollectionViewCell {
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var removeButton: ButtonWithIndex!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    var featureName: String!
    
    func updateUI() {
        if featureName == nil {
            return
        }
        let badgeCount = HydraController.sharedInstance.logonUser.badgeCount(recordType: featureName.formattedRecordType() ?? "")
        if badgeCount == 0 {
            badgeLabel.isHidden = true
        } else {
            badgeLabel.isHidden = false
            let widthOneNumber: CGFloat = 20
            let widthTwoNumbers: CGFloat = 25
            let maximumBadge = 99
            badgeLabel.frame.size.width = badgeCount < 10 ? widthOneNumber : widthTwoNumbers
            
            if badgeCount <= maximumBadge {
                badgeLabel.text = "\(badgeCount)"
            } else {
                badgeLabel.text = "\(maximumBadge)"
            }
        }
        iconImage.setImage(featureName: featureName)
        titlelabel.text = featureName.formattedFeatureName()
    }
}
