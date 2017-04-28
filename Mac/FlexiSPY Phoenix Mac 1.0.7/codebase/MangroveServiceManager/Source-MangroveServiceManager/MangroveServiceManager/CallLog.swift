//
//  CallLog.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class CallLog: NSObject {
    public var phoneNumber: String?
    public var contactName: String?
    public var userTime: String?
    public var systemTime: String?
    public var duration: Int?
    public var recordDirection: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        phoneNumber = dict["phoneNumber"] as? String
        contactName = dict["contactName"] as? String
        userTime = dict["userTime"] as? String
        systemTime = dict["systemTime"] as? String
        duration = dict["duration"] as? Int
        recordDirection = dict["recordDirection"] as? String
    }
}
