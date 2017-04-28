//
//  MSGetAccountProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/13/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire

class MSGetAccountProcessor: MSProcessor {
    override func execute() {
        url = URL(string: MSContext.baseUrl + "/api/account/getAccount")
        params = [String: String]()
        headers = self.httpHeaders()
        method = HTTPMethod.get
        super.execute()
    }
    
    override func parse(response: Dictionary<AnyHashable, Any>) -> MSResponse? {
        let castedResponse = response as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return MSResponseParser.parseGetAccountResponse(response: castedResponse)
    }
}
