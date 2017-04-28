//
//  Mail.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/21/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation
import MangroveServiceManager

extension Mail {
    func formattedRecipientsAsString(recipientType: String) -> String? {
        guard let items = self.recipients else {
            return nil
        }
        var returnedString = ""
        let seperator = ", "
        for item in items where item.recipientType == recipientType {
            if item == items.last {
                returnedString += item.recipientName ?? ""
            }else {
                returnedString += item.recipientName ?? "" + seperator
            }
        }
        return returnedString
    }
    
}
