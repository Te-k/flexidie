//
//  IntExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation

extension Int {
    func toFormattedDurationString() -> String? {
        
        if self == 0 {
            return "00:00"
        }
        
        let hour = Int(self / 3600)
        let minute = Int((self / 60)%60)
        let second = Int(self % 60)
        
        let hourString = hour < 10 ? "0\(hour)" : "\(hour)"
        let minuteString = minute < 10 ? "0\(minute)" : "\(minute)"
        let secondString = second < 10 ? "0\(second)" : "\(second)"
        
        if hour > 0 {
            return "\(hourString):\(minuteString):\(secondString)"
        }
        else {
            return "\(minuteString):\(secondString)"
        }
    }
}
