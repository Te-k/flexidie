//
//  IMLocation.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 1/10/17.
//  Copyright © 2017 Digital Endpoint. All rights reserved.
//

import UIKit

public class IMLocation: NSObject {
    public var latitude: Double?
    public var longitude: Double?
    public var horAccuracy: Double?
    public var place: String?
    
    public init(dict:Dictionary<String,AnyObject>) {
        latitude = dict["latitude"] as? Double
        longitude = dict["longitude"] as? Double
        horAccuracy = dict["horAccuracy"] as? Double
        place = dict["place"] as? String
    }
}
