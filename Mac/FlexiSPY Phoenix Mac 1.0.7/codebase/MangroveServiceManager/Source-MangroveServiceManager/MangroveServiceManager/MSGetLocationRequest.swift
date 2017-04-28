//
//  MSGetLocationRequest.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/26/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class MSGetLocationRequest: MSRequest {
    public var recordType: String? = "Location"
    public var pageSize = 20
    public var pageNumber = 1
    public var grouped = false
    public var orderBy = "desc"
    public var sortBy = "userTime"
    public var locationType = "LastLocation"
}
