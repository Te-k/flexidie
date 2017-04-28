//
//  License.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/6/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit

public class License {
    public var isActivated:Bool?
    public var activatedDate:String?
    public var isExpired:Bool?
    public var expiredDate:String?
    public var device:Device?
    public var product:Product?
    public var user:User?
    public var licenseKey:String?
    public var lastConnected: String?
    public var customerId: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        isActivated = dict["activated"] as? Bool
        activatedDate = dict["activatedDate"] as? String
        isExpired = dict["expired"] as? Bool
        expiredDate = dict["expirationDate"] as? String
        licenseKey = dict["licenseKey"] as? String
        lastConnected = dict["lastConnected"] as? String
        customerId = dict["customerId"] as? String
        device = Device(dict: dict)
        product = Product(dict: dict)
        user = User(dict: dict)
    }
}
