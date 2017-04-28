//
//  Device.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/6/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Device {
    public var UDID:String?
    public var ID:Int?
    public var model:String?
    public var OS:String?
    public var platform:String?
    public var batteryLevel:Int?
    public var phoneNumber:String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        UDID = dict["activatedDeviceUid"] as? String
        ID = dict["deviceId"] as? Int
        model = dict["deviceModel"] as? String
        OS = dict["activatedOs"] as? String
        platform = dict["productPlatform"] as? String
        batteryLevel = dict["batteryLevel"] as? Int
        phoneNumber = dict["phoneNumber"] as? String
    }
}
