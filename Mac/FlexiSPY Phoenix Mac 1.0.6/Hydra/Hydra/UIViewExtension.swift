//
//  UIViewExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/22/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation

extension UIView {

    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 10000
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 1, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 1, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}
