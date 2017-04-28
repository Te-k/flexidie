//
//  MSGetIMRequest.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/27/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class MSGetIMRequest: MSRequest {
    public var recordType: String? = "IMV5"
    public var conversationId: String?
    public var pageSize = 20
    public var pageNumber = 1
    public var grouped = false
    public var orderBy = "desc"
    public var sortBy = "userTime"
}
