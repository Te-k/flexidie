//
//  Contact.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class Contact: NSObject {
    public var email: String?
    public var mobilePhoneNumber: String?
    public var workPhoneNumber: String?
    public var homePhoneNumber: String?
    public var firstname: String?
    public var lastname: String?
    public var contactId: Int?
    public var notes: String?
    public var approvalStatus: String?
    public var contactPicURL: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        email = dict["email"] as? String
        mobilePhoneNumber = dict["mobilePhoneNumber"] as? String
        workPhoneNumber = dict["workPhoneNumber"] as? String
        homePhoneNumber = dict["homePhoneNumber"] as? String
        firstname = dict["firstname"] as? String
        lastname = dict["lastname"] as? String
        contactId = dict["contactId"] as? Int
        notes = dict["notes"] as? String
        approvalStatus = dict["approvalStatus"] as? String
        contactPicURL = dict["contactPicURL"] as? String
    }
}
