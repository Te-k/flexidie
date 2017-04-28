//
//  MSGetIMConversationProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetIMConversationProcessor: MSProcessor {
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/record/getRecords")
        params = [String: Any]()
        if let _request = request as? MSGetIMConversationRequest {
            params?["deviceId"] = _request.deviceId
            params?["recordType"] = _request.recordType
            params?["sortBy"] = _request.sortBy
            params?["orderBy"] = _request.orderBy
            params?["grouped"] = _request.grouped
            params?["pageSize"] = _request.pageSize
        }
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return MSResponseParser.parseGetIMConversationResponse(response: castedResponse)
    }
}
