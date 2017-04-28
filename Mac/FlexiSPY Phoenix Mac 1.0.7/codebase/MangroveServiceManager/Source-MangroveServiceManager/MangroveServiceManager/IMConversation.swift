//
//  IMConversation.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class IMConversation: NSObject {
    public var conversationName: String?
    public var conversationId: String?
    public var imV5Service: String?
    public var recordStatus: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        conversationName = dict["conversationName"] as? String
        conversationId = dict["conversationId"] as? String
        imV5Service = dict["imV5Service"] as? String
        recordStatus = dict["recordStatus"] as? String
    }
}
