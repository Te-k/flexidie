//
//  MSProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/2/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MSProcessor {
    var delegate: MSController?
    var selector: Selector?
    var request: MSRequest?
    var method: HTTPMethod?
    var url: URL?
    var params: [String: Any]?
    var headers: HTTPHeaders?
    
    init(request: MSRequest) {
        self.request = request
    }
    
    func execute() {
        Alamofire.request(url!, method:method!, parameters:params, encoding: URLEncoding.default ,headers:headers).responseJSON {
            
            response in
            
            if response.result.error != nil {
                var dict = Dictionary<AnyHashable,Any>()
                dict["response"] = response
                let error = NSError(domain:"Mangrove Error", code: response.response?.statusCode ?? 0 , userInfo: dict)
                self.delegate?.requestFinished(request: self.request!, response: nil, error:error)
            }
            else if let requestResponse = response.result.value {
                let jsonObject = JSON(requestResponse)
                if let status = jsonObject.dictionaryObject?["status"] as? String
                    , status == "OK"
                {
                    let mangroveResponse = self.parse(response: jsonObject.dictionaryObject!)
                    self.delegate?.requestFinished(request: self.request!, response: mangroveResponse, error: nil)
                } else {
                    var dict = Dictionary<AnyHashable,Any>()
                    dict["response"] = jsonObject.dictionaryObject
                    
                    var error:NSError
                    if let errors = jsonObject.dictionaryObject?["errors"] as? [Dictionary<String,Any>]
                        , let errorCode = errors.first?["errorCode"] as? Int {
                        error = NSError(domain: "Mangrove Error: ", code: errorCode, userInfo:jsonObject.dictionaryObject)
                    }
                    else if let errorMessage = jsonObject.dictionaryObject?["errorMessage"] as? String {
                        error = NSError(domain: "Mangrove Error: " + errorMessage , code: response.response?.statusCode ?? 0, userInfo:jsonObject.dictionaryObject)
                    }
                    else {
                        // in case of errors object not exist.
                        error = NSError(domain: "Mangrove Error: ", code: response.response?.statusCode ?? 0, userInfo:jsonObject.dictionaryObject)
                    }
                    self.delegate?.requestFinished(request: self.request!, response: nil, error:error)
                }
            }
        }
    }
    
    func httpHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders()
        if let jsid = request?.JSID {
            headers["Cookie"] = "JSESSIONID=\(jsid)"
        }
        return headers
    }
    
    func parse(response:Dictionary<AnyHashable,Any>) -> MSResponse? {
        return nil
    }
}
