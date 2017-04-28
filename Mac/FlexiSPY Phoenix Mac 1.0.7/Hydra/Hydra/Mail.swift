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
        var displayName = ""
        
        guard let recipients = self.recipients else {
            return displayName
        }
        
        for recipient in recipients where recipient.recipientType == recipientType {
            if recipients.last == recipient{
                displayName += "\(recipient.recipientDetails ?? "")"
            } else {
                displayName += "\(recipient.recipientDetails ?? ""), "
            }
            
        }
        return displayName
    }
    
    public var senderDisplayName: String? {
        get {
            if let senderContactName = self.senderContactName,
                senderContactName.characters.count > 0
            {
                return senderContactName
            } else {
                return senderEmail
            }
        }
    }
}
