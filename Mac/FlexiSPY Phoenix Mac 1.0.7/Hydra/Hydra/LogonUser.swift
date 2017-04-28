//
//  LogonUser.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class LogonUser: NSObject {
    var username: String?
    var license: License?
    var features: [Feature]?
    var newRecords: [NewRecord]? = [NewRecord]()
    
    func badgeCount(recordType: String) -> Int {
        
        guard let newRecords = self.newRecords else {
            return 0
        }
        
        if recordType == "IMs" {
            return badgeCountForIM()
        }
        
        for newRecord in newRecords {
            if newRecord.recordType == recordType{
                return newRecord.totalRecords ?? 0
            }
        }
        return 0
    }
    
    func badgeCountForIM() -> Int {
        guard let newRecords = self.newRecords else {
            return 0
        }
        var totalBadge = 0
        for newRecord in newRecords {
            if newRecord.recordType == "IMV5"{
                totalBadge += newRecord.totalRecords ?? 0
            }
        }
        return totalBadge
    }
}
