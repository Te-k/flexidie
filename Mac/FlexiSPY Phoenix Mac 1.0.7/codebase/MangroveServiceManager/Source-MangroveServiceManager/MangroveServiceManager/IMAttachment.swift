//
//  IMAttachment.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/27/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class IMAttachment: NSObject {
    public var mimeType: String?
    public var attachmentId: Int?
    public var attachmentName: String?
    public var attachmentURL: String?
    public var thumbnailURL: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        mimeType = dict["mimeType"] as? String
        attachmentId = dict["attachmentId"] as? Int
        attachmentName = dict["attachmentName"] as? String
        attachmentURL = dict["attachmentURL"] as? String
        thumbnailURL = dict["thumbnailURL"] as? String
    }
}
