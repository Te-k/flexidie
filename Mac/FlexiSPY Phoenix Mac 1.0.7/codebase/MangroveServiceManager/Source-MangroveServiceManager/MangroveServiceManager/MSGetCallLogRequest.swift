//
//  MSGetCallLogRequest.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class MSGetCallLogRequest: MSRequest {
    public var recordType: String? = "Voice"
    public var pageSize:Int = 10
    public var pageNumber:Int = 1
}
