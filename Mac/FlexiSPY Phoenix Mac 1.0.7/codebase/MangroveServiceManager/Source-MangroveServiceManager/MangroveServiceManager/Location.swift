//
//  Location.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/26/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class Location: NSObject {
    public var latitude: Double?
    public var longitude: Double?
    public var cellId: Int?
    public var cellName: String?
    public var horizontalAccuracy: Double?
    public var userTime: String?
    public var systemTime: String?
    public var deviceUid: String?
    
    public init(dict: Dictionary<String,AnyObject>) {
        latitude = dict["latitude"] as? Double
        longitude = dict["longitude"] as? Double
        cellId = dict["cellId"] as? Int
        cellName = dict["cellName"] as? String
        horizontalAccuracy = dict["horizontalAccuracy"] as? Double
        userTime = dict["userTime"] as? String
        systemTime = dict["systemTime"] as? String
        deviceUid = dict["deviceUid"] as? String
    }
    
    public override init() { }
}
