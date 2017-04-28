//
//  MSLogoutProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/13/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MSLogoutProcessor: MSProcessor {

    override func execute() {
        let url = URL(string:MSContext.baseUrl + "/api/logout")
        var params = httpHeaders()

        Alamofire.request(url!, method: .post, parameters: params, encoding: URLEncoding.default , headers: nil).responseJSON {
            response in
            
            if let error = response.result.error {
                self.delegate?.requestFinished(request: self.request!, response: nil, error: error as NSError?)
            } else {
                let responseObject = response.result.value
                let jsonObject = JSON(responseObject!)
                let status = jsonObject.dictionaryObject?["status"] as! String?
                if status == "OK" {
                    let responseLogout = MSLogoutResponse()
                    responseLogout.status = status
                    responseLogout.message = jsonObject.dictionaryObject?["message"] as? String
                    self.delegate?.requestFinished(request: self.request!, response: responseLogout, error: nil)
                } else {
                    let errorMessage = jsonObject.dictionaryObject?["message"] as? String
                    let userInfo = jsonObject.dictionaryValue
                    let error = NSError(domain: "Error:\(errorMessage)", code: (response.response?.statusCode)!, userInfo: userInfo)
                    self.delegate?.requestFinished(request: self.request!, response: nil, error: error)
                }
            }
        }
    }

}
