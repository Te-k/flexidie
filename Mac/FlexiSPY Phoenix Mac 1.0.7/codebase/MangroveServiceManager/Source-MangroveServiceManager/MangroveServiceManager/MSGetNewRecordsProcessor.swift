//
//  MSGetNewRecordsProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 1/9/17.
//  Copyright © 2017 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetNewRecordsProcessor: MSProcessor {
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/record/getNewRecordCounts")
        params = [String: Any]()
        if let _request = request as? MSGetNewRecordsRequest {
            params?["deviceId"] = _request.deviceId
        }
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return MSResponseParser.parseGetNewRecordsResponse(response: castedResponse)
    }
}
