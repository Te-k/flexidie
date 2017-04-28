//
//  Feature.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class Feature: NSObject {
    public var featureId: Int?
    public var featureName: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        featureId = dict["featureId"] as? Int
        featureName = dict["featureName"] as? String
    }
}
