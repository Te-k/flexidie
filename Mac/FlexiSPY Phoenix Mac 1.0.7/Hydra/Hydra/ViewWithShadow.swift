//
//  ViewWithShadow.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/6/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import UIKit

class ViewWithShadow: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.1)
        layer.shadowOpacity = 0.2
        layer.shadowPath = shadowPath.cgPath
    }
}
