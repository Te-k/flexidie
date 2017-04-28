//
//  MSGetAddressBookProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetAddressBookProcessor: MSProcessor {
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/record/getRecords")
        params = [String: Any]()
        if let _request = request as? MSGetAddressBookRequest {
            params?["deviceId"] = _request.deviceId
            params?["pageSize"] = _request.pageSize
            params?["recordType"] = _request.recordType
            params?["pageNumber"] = _request.pageNumber
            params?["approvalStatus"] = _request.approvalStatus
        }
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return MSResponseParser.parseGetAddressBookResponse(response: castedResponse)
    }
}
