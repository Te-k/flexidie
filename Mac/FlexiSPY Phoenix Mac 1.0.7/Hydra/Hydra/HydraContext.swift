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
    static let HydraChangeDeviceNotification = "HydraChangeDeviceNotification"
    static let FeaturesPersistKey = "FeaturesPersistKey"
    static let AvailableFeatures = [
        "Call",
        "AddressBook",
        "SMS",
        "CameraImage",
        "Email",
        "Location",
    ]
    
    static let ExcludedChronologicalFeatures = [
        "AddressBook"
    ]
    
    static let IMFeature = "IMs"
    
    static let IMServices = [
        "IMWhatsApp",
        "IMLINE",
        "IMFacebook",
        "IMSkype",
        "IMBBM",
        "IMWeChat",
        "IMYahooMessenger",
        "IMSnapchat",
        "IMHangout",
        "IMKIKMessenger",
        "IMTelegram",
        "IMTinder",
        "IMQQMessenger",
        "IMInstagram",
        "IMHikeMessenger",
    ]
    
    static let iconAudioUrl = "https://portal.flexispy.com/img/default-icons/glyph-sound.png"
}
