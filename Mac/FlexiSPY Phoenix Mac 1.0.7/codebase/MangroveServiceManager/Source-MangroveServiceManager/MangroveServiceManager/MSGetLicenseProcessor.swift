//
//  MSGetLicenseProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/6/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetLicenseProcessor: MSProcessor {
    
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/license/getLicenses")
        params = [String: String]()
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return MSResponseParser.parseGetLicenseResponse(response: castedResponse)
    }
}
