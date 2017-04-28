//
//  GroupedSMS.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/19/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class GroupedSMS: SMS {
    public var count: Int?
    public var recentMessages: String?
    
    public override init(dict: Dictionary<String,AnyObject>) {
        super.init(dict: dict)
        count = dict["count"] as? Int
        recentMessages = dict["recentMessages"] as? String
    }
}
