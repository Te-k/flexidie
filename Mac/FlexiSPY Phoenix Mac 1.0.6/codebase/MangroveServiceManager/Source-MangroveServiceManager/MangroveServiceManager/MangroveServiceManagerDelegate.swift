//
//  MangroveServiceManagerDelegate.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/2/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import Foundation

public protocol MangroveServiceManagerDelegate: NSObjectProtocol {
    func requestCompleted(request: MSRequest, response: MSResponse?)
    func requestError(error: Error?)
}
