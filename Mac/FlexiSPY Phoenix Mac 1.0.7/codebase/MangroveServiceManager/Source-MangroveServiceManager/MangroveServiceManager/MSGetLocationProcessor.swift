//
//  MSGetLocationProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/26/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetLocationProcessor: MSProcessor {
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/record/getRecords")
        params = [String: Any]()
        if let _request = request as? MSGetLocationRequest {
            params?["deviceId"] = _request.deviceId
            params?["recordType"] = _request.recordType
            params?["sortBy"] = _request.sortBy
            params?["orderBy"] = _request.orderBy
            params?["locationType"] = _request.locationType
            params?["grouped"] = _request.grouped
        }
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return MSResponseParser.parseGetlocationResponse(response: castedResponse)
    }
}
