//
//  MSGetAddressBookRequest.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class MSGetAddressBookRequest: MSRequest {
    public var recordType: String? = "AddressBook"
    public var pageSize:Int = 20
    public var pageNumber:Int = 1
    public var approvalStatus = "All"
}
