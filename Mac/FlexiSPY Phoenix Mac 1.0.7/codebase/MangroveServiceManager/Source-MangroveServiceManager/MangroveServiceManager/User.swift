//
//  User.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/6/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import SwiftyJSON

public class User: NSObject {
    public var userAccountID:Int?
    public var userEmail:String?
    public var userName:String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        userAccountID = dict["userAccountId"] as? Int
        userEmail = dict["userEmail"] as? String
        userName = dict["username"] as? String
    }
}
