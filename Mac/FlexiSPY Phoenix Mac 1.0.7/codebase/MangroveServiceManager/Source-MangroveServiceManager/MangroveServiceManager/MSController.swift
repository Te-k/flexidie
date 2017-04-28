//
//  MSController.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/2/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit
import SwiftyJSON

public class MSController: NSObject, MangroveServiceManager, ProcessorDelegate {
    
    public func send(request: MSRequest) {
        var processor:MSProcessor?
        if request is MSAuthenticationRequest {
            processor = MSAuthenticationProcessor(request: request)
        } else if request is MSGetLicenseRequest {
            processor = MSGetLicenseProcessor(request: request)
        } else if request is MSLogoutRequest {
            processor = MSLogoutProcessor(request: request)
        } else if request is MSGetAccountRequest {
            processor = MSGetAccountProcessor(request: request)
        } else if request is MSGetSupportedFeaturesRequest {
            processor = MSGetSupportedFeaturesProcessor(request: request)
        } else if request is MSGetCallLogRequest {
            processor = MSGetCallLogProcessor(request: request)
        } else if request is MSGetAddressBookRequest {
            processor = MSGetAddressBookProcessor(request: request)
        } else if request is MSGetSMSRequest {
            processor = MSGetSMSProcessor(request: request)
        } else if request is MSGetCameraImageRequest {
            processor = MSGetCameraImageProcessor(request: request)
        } else if request is MSGetMailRequest {
            processor = MSGetMailProcessor(request: request)
        } else if request is MSGetLocationRequest {
            processor = MSGetLocationProcessor(request: request)
        } else if request is MSGetIMRequest {
            processor = MSGetIMProcessor(request: request)
        } else if request is MSGetIMConversationRequest {
            processor = MSGetIMConversationProcessor(request: request)
        } else if request is MSGetNewRecordsRequest {
            processor = MSGetNewRecordsProcessor(request: request)
        }
        processor?.delegate = self
        processor?.execute()
    }
    
    func requestFinished(request: MSRequest, response: MSResponse?, error: NSError?) {
        if let err = error {
            request.delegate?.requestError(error: err)
        } else {
            request.delegate?.requestCompleted(request:request, response: response)
        }
    }
}
