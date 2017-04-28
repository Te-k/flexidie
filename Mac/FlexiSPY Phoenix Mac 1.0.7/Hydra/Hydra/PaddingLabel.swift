//
//  LabelWithPadding.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/19/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 6.0
    @IBInspectable var bottomInset: CGFloat = 6.0
    @IBInspectable var leftInset: CGFloat = 8.0
    @IBInspectable var rightInset: CGFloat = 20.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}
