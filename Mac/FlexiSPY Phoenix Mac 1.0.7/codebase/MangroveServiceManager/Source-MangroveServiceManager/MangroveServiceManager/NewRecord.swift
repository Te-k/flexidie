//
//  NewRecord.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 1/9/17.
//  Copyright © 2017 Digital Endpoint. All rights reserved.
//

import Foundation
public class NewRecord: NSObject {
    public var recordType: String?
    public var totalRecords: Int?
    
    public init(dict: Dictionary<String,AnyObject>) {
        recordType = dict["recordType"] as? String
        totalRecords = dict["totalRecords"] as? Int
    }
}
