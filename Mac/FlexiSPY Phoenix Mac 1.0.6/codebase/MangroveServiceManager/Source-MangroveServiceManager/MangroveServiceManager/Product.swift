//
//  Product.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/6/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Product {
    public var ID:String?
    public var version:String?
    public var configurationID:Int?
    
    init(dict:Dictionary<String,AnyObject>) {
        ID = dict["activatedProductId"] as? String
        version = dict["activatedProductVersion"] as? String
        configurationID = dict["configurationId"] as? Int
    }
}
