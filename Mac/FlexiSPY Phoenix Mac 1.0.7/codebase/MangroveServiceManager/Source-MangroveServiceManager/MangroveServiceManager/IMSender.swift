//
//  IMParticipant.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import Foundation

public class IMSender {
    public var ID: String?
    public var name: String?
    public var profileImageUrl: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        guard let recordDirection = dict["recordDirection"] as? String else {
            return
        }
        
        switch recordDirection {
        case "In":
            if let messageOriginator = dict["messageOriginator"] as? [String: Any] {
                ID = messageOriginator["contactId"] as? String
                name = messageOriginator["contactDisplayName"] as? String
                profileImageUrl = messageOriginator["contactPictureProfileURL"] as? String
            }
        case "Out":
            if let messageOriginator = dict["accountOwner"] as? [String: Any] {
                ID = messageOriginator["ownerId"] as? String
                name = messageOriginator["ownerDisplayName"] as? String
                profileImageUrl = messageOriginator["ownerPictureProfileURL"] as? String
            }
        default:
            break
        }
    }
}
