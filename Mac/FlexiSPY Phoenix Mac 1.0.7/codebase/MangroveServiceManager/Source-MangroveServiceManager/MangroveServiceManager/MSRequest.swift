//
//  MSRequest.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/2/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import Alamofire

public class MSRequest: NSObject {
    public var delegate: MangroveServiceManagerDelegate?
    public var JSID: String?
    public var deviceId: Int?
}
