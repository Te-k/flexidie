//
//  HydraContext.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/16/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation

struct HydraContext {
    static let HydraLogoutNotification = "HydraLogoutNotification"
    static let FeaturesPersistKey = "FeaturesPersistKey"
    static let AvailableFeatures = [
        "Call",
        "AddressBook",
        "SMS",
        "CameraImage",
        "Email",
        "Location"
    ]
}
