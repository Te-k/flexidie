//
//  MSResponseParser.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/6/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import UIKit

class MSResponseParser {
     static func parseGetLicenseResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let getLicenseReponse = MSGetLicenseResponse()
        if let licenseArray = response["licenses"] as? [Any] {
            for license in licenseArray {
                switch license {
                case let tempDict as Dictionary<String,AnyObject>:
                    let license = License(dict: tempDict)
                    getLicenseReponse.licenses?.append(license)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        return getLicenseReponse
    }
    
    static func parseGetAccountResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let getAccountResponse = MSGetAccountResponse()
        let accountDict = response["account"] as! [String:AnyObject]
        let account = Account(dict: accountDict)
        getAccountResponse.account = account
        return getAccountResponse
    }
    
    static func parseGetSupportedFeaturesResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let getSupportedFeaturesResponse = MSGetSupportedFeaturesResponse()
        if let featureArray = response["supportedFeatures"] as? [Any] {
            for feature in featureArray {
                switch feature {
                case let tempDict as Dictionary<String,AnyObject>:
                    let feature = Feature(dict: tempDict)
                    getSupportedFeaturesResponse.features?.append(feature)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        
        return getSupportedFeaturesResponse
    }
    
    static func parseGetCallLogResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let responseObject = MSGetCallLogResponse()
            responseObject.pageNumber = response["pageNumber"] as? Int ?? 1
            responseObject.totalPages = response["totalPages"] as? Int ?? 0
        if let items = response["records"] as? [Any] {
            for item in items {
                switch item {
                case let tempDict as Dictionary<String,AnyObject>:
                    let object = CallLog(dict: tempDict)
                    responseObject.callLogs?.append(object)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        
        return responseObject
    }
    
    static func parseGetAddressBookResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let responseObject = MSGetAddressBookResponse()
        responseObject.pageNumber = response["pageNumber"] as? Int ?? 1
        responseObject.totalPages = response["totalPages"] as? Int ?? 0
        if let items = response["records"] as? [Any] {
            let firstAddressBook = items.first as? Dictionary<String,AnyObject>
            let contacts = firstAddressBook?["contacts"] as? [Any] ?? [Any]()
            for item in contacts {
                switch item {
                case let tempDict as Dictionary<String,AnyObject>:
                    let object = Contact(dict: tempDict)
                    responseObject.contacts?.append(object)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        
        return responseObject
    }
    
    static func parseGetSMSResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let responseObject = MSGetSMSResponse()
        responseObject.pageNumber = response["pageNumber"] as? Int ?? 1
        responseObject.totalPages = response["totalPages"] as? Int ?? 0
        if let items = response["records"] as? [Any] {
            for item in items {
                switch item {
                case let tempDict as Dictionary<String,AnyObject>:
                    let object = SMS(dict: tempDict)
                    responseObject.smses?.append(object)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        
        return responseObject
    }
    
    static func parseGetGroupedSMSResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let responseObject = MSGetSMSResponse()
        responseObject.pageNumber = response["pageNumber"] as? Int ?? 1
        responseObject.totalPages = response["totalPages"] as? Int ?? 0
        if let items = response["records"] as? [Any] {
            for item in items {
                switch item {
                case let tempDict as Dictionary<String,AnyObject>:
                    let object = GroupedSMS(dict: tempDict)
                    responseObject.smses?.append(object)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        
        return responseObject
    }
    
    static func parseGetCameraImageResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let responseObject = MSGetCameraImageResponse()
        responseObject.pageNumber = response["pageNumber"] as? Int ?? 1
        responseObject.totalPages = response["totalPages"] as? Int ?? 0
        if let items = response["records"] as? [Any] {
            for item in items {
                switch item {
                case let tempDict as Dictionary<String,AnyObject>:
                    let object = CameraImage(dict: tempDict)
                    responseObject.images?.append(object)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        
        return responseObject
    }
    
    static func parseGetMailResponse(response: Dictionary<String, Any>) -> MSResponse? {
        let responseObject = MSGetMailResponse()
        responseObject.pageNumber = response["pageNumber"] as? Int ?? 1
        responseObject.totalPages = response["totalPages"] as? Int ?? 0
        if let items = response["records"] as? [Any] {
            for item in items {
                switch item {
                case let tempDict as Dictionary<String,AnyObject>:
                    let object = Mail(dict: tempDict)
                    responseObject.mails?.append(object)
                default:
                    print("Cannot cast to Dictionary")
                }
            }
        }
        
        return responseObject
    }
}
