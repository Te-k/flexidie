//
//  MSGetSupportedFeaturesProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetSupportedFeaturesProcessor: MSProcessor {
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/getSupportedFeatures")
        params = [String: Any]()
        if let _request = request as? MSGetSupportedFeaturesRequest {
            params?["deviceId"] = _request.deviceId
        }
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return MSResponseParser.parseGetSupportedFeaturesResponse(response: castedResponse)
    }
}
