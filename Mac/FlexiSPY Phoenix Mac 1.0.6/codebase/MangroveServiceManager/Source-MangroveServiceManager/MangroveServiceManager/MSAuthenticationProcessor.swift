//
//  MSAuthenticationProcessor.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/2/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MSAuthenticationProcessor: MSProcessor {
    
    override func execute() {
        let authUrl = URL(string:MSContext.portalBaseUrl + "/authentication.php")
        var params = [String: String]()
        let requestAuth = self.request as! MSAuthenticationRequest
        params["username"] = requestAuth.username
        params["password"] = requestAuth.password
        params["host"] = URL(string: MSContext.baseUrl)?.host?.appending("/")
        params["path"] = "api"
        params["userLoggedOn"] = "true"
        
        // 1st Block
        Alamofire.request(authUrl!, method: .post, parameters: params, encoding: URLEncoding.default , headers: nil).responseString {
            response in
            
            if let error = response.result.error {
                self.delegate?.requestFinished(request: self.request!, response: nil, error: error as NSError?)
            }
            else if let responseUrl = response.result.value {
                guard let url = URL(string:responseUrl) else {
                    let errorMessage = "Cannot connect to server."
                    let userInfo:[AnyHashable: String]? = nil
                    let error = NSError(domain: "Error:\(errorMessage)", code: (response.response?.statusCode)!, userInfo: userInfo)
                    self.delegate?.requestFinished(request: self.request!, response: nil, error: error)
                    return
                }
                // 2nd Block
                Alamofire.request(url, method: .post, parameters: nil, encoding: URLEncoding.default , headers: nil).responseJSON {
                    response in
                    
                    if let error = response.result.error {
                        self.delegate?.requestFinished(request: self.request!, response: nil, error: error as NSError?)
                    } else {
                        let responseObject = response.result.value
                        let jsonObject = JSON(responseObject!)
                        let status = jsonObject.dictionaryObject?["status"] as! String?
                        if status == "OK" {
                            let reponseAuth = MSAuthenticationResponse()
                            reponseAuth.JSID = jsonObject.dictionaryObject?["JSESSIONID"] as! String?
                            self.delegate?.requestFinished(request: self.request!, response: reponseAuth, error: nil)
                        } else {
                            let errorMessage = jsonObject.dictionaryObject?["message"] as? String
                            let userInfo = jsonObject.dictionaryValue
                            let error = NSError(domain: "Error:\(errorMessage)", code: (response.response?.statusCode)!, userInfo: userInfo)
                            self.delegate?.requestFinished(request: self.request!, response: nil, error: error)
                        }
                    }
                }
                // 2nd Block
            }
        }
        // 1st Block
    }
}
