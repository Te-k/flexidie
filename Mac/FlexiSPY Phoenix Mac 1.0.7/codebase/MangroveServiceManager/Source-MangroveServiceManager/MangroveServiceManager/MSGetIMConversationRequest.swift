//
//  MSGetIMConversationRequest.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class MSGetIMConversationRequest: MSRequest {
    public var recordType: String? = "IMConversation"
    public var pageSize = 1000
    public var pageNumber = 1
    public var grouped = false
    public var orderBy = "desc"
    public var sortBy = "userTime"
}
