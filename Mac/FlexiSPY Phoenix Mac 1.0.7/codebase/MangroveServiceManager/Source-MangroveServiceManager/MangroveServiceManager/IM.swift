//
//  InstantMessage.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/27/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class IM: NSObject {
    public var recordDirection: String?
    public var imV5Service: String?
    public var data: String?
    public var hasText: Bool?
    public var hasContact: Bool?
    public var hasShareLocation: Bool?
    public var hasSticker: Bool?
    public var userTime: String?
    public var systemTime: String?
    public var conversationId: String?
    public var attachments: [IMAttachment]? = [IMAttachment]()
    public var sender: IMSender?
    public var location: IMLocation?

    public init(dict:Dictionary<String,AnyObject>) {
        recordDirection = dict["recordDirection"] as? String
        imV5Service = dict["imV5Service"] as? String
        data = dict["data"] as? String
        hasText = dict["hasText"] as? Bool
        hasContact = dict["hasContact"] as? Bool
        hasShareLocation = dict["hasShareLocation"] as? Bool
        hasSticker = dict["hasSticker"] as? Bool
        userTime = dict["userTime"] as? String
        systemTime = dict["systemTime"] as? String
        sender = IMSender(dict: dict)
        
        if let conversation = dict["conversation"] as? Dictionary<String, AnyObject>,
            let conversationId = conversation["conversationId"] as? String {
            self.conversationId = conversationId
        }
        
        if let attachmentsAsDict = dict["attachments"] as? [Dictionary<String, AnyObject>] {
            for tempDict in attachmentsAsDict {
                let attachment = IMAttachment(dict: tempDict)
                self.attachments?.append(attachment)
            }
        }
        
        if let locationAsDict = dict["shareLocation"] as? Dictionary<String, AnyObject> {
            let location = IMLocation(dict: locationAsDict)
            self.location = location
        }
    }
    
}
