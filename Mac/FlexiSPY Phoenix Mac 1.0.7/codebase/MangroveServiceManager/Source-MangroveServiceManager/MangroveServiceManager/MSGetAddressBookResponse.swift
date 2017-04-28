//
//  MSGetAddressBookResponse.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class MSGetAddressBookResponse: MSResponse {
    public var contacts:[Contact]? = [Contact]()
    public var userTime: String?
    public var systemTime: String?
}
