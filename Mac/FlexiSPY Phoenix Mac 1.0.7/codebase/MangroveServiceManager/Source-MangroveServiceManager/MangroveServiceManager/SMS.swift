//
//  SMS.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/16/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class SMS: NSObject {
    public var senderName: String?
    public var senderNumber: String?
    public var userTime: String?
    public var systemTime: String?
    public var smsData: String?
    public var recordDirection: String?
    
    public init(dict: Dictionary<String,AnyObject>) {
        senderName = dict["senderName"] as? String
        senderNumber = dict["senderNumber"] as? String
        userTime = dict["userTime"] as? String
        systemTime = dict["systemTime"] as? String
        smsData = dict["smsData"] as? String
        recordDirection = dict["recordDirection"] as? String
    }
}
