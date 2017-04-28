//
//  MSGetSMSProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/16/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetSMSProcessor: MSProcessor {
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/record/getRecords")
        params = [String: Any]()
        if let _request = request as? MSGetSMSRequest {
            params?["deviceId"] = _request.deviceId
            params?["pageSize"] = _request.pageSize
            params?["recordType"] = _request.recordType
            params?["pageNumber"] = _request.pageNumber
            params?["sortBy"] = _request.sortBy
            params?["orderBy"] = _request.orderBy
            params?["grouped"] = _request.grouped
            params?["senderNumber"] = _request.senderNumber
            params?["contactName"] = _request.contactName
        }
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        
        guard let smsRequest = request as? MSGetSMSRequest else {
            return nil
        }
        
        if smsRequest.grouped == true {
            return MSResponseParser.parseGetGroupedSMSResponse(response: castedResponse)
        } else {
            return MSResponseParser.parseGetSMSResponse(response: castedResponse)
        }
        
    }
}
