//
//  Email.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class Mail: NSObject {
    public var subject: String?
    public var mailBody: String?
    public var senderEmail: String?
    public var senderContactName: String?
    public var recordDirection: String?
    public var recordType: String?
    public var userTime: String?
    public var attachments: [Attachment]? = [Attachment]()
    public var recipients: [Recipient]? = [Recipient]()
        
    public init(dict:Dictionary<String,AnyObject>) {
        subject = dict["subject"] as? String
        mailBody = dict["mailBody"] as? String
        senderEmail = dict["senderEmail"] as? String
        senderContactName = dict["senderContactName"] as? String
        recordDirection = dict["recordDirection"] as? String
        recordType = dict["recordType"] as? String
        userTime = dict["userTime"] as? String
        
        if let attachments = dict["attachments"] as? [Dictionary<String, AnyObject>] {
            for dict in attachments {
                let object = Attachment(dict: dict)
                self.attachments?.append(object)
            }
        }
        
        if let attachments = dict["recipients"] as? [Dictionary<String, AnyObject>] {
            for dict in attachments {
                let object = Recipient(dict: dict)
                self.recipients?.append(object)
            }
        }
    }
}
