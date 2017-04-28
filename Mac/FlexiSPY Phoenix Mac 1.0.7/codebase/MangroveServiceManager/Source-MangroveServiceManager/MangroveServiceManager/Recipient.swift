//
//  Recipient.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/21/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class Recipient: NSObject {
    public var recipientDetails: String?
    public var recipientType: String?
    public var recipientName: String?

    public init(dict:Dictionary<String,AnyObject>) {
        recipientDetails = dict["recipientDetails"] as? String
        recipientType = dict["recipientType"] as? String
        recipientName = dict["recipientName"] as? String
    }
}
