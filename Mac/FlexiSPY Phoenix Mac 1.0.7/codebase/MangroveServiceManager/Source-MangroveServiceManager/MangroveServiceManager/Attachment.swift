//
//  Attachment.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/21/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class Attachment: NSObject {
    public var attachmentURL: String?
    public var attachmentName: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        attachmentURL = dict["attachmentURL"] as? String
        attachmentName = dict["attachmentName"] as? String
    }
}
