//
//  ProcessorDelegate.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/8/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import Foundation

protocol ProcessorDelegate: NSObjectProtocol {
    func requestFinished(request: MSRequest, response: MSResponse?, error: NSError?)
}
