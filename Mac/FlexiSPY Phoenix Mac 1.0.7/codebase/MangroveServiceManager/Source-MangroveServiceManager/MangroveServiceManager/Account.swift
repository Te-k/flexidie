//
//  Account.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/13/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class Account {
    public var firstname: String?
    public var lastname: String?
    public var userId: String?
    public var email: String?
    public var smsCreditBalance: Int?
    
    public init(dict:Dictionary<String,AnyObject>) {
        firstname = dict["firstname"] as? String
        lastname = dict["lastname"] as? String
        userId = dict["userId"] as? String
        email = dict["email"] as? String
        smsCreditBalance = dict["smsCreditBalance"] as? Int
    }
}
