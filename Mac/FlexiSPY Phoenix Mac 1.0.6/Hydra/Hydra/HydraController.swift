//
//  HydraController.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/13/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import MangroveServiceManager
class HydraController: NSObject {
    private override init() {
        print("Singleton just created.")
    }
    let msController: MSController = MSController()
    var JSID:String?
    static let sharedInstance = HydraController()
    var logonUser: LogonUser = LogonUser()
    
    func persistedFeaturesWithLogonUser() -> [String]? {
        guard let username = HydraController.sharedInstance.logonUser.username ,
            let persistedFeatures = UserDefaults.standard.object(forKey: username) as? [String] else {
            return nil
        }
        return persistedFeatures
    }
    
    func persistFeaturesWithLogonUser(features:[String]) {
        guard let username = HydraController.sharedInstance.logonUser.username else {
            return
        }
        UserDefaults.standard.set(features, forKey: username)
    }
    
    func supportedFeatureNames() -> [String]? {
        let features = HydraController.sharedInstance.logonUser.features ?? [Feature]()
        var featureNames = [String]()
        for feature in features {
            let availableFeatures = HydraContext.AvailableFeatures
            if let _featureName = feature.featureName
                , availableFeatures.contains(_featureName)
            {
                featureNames.append(_featureName)
            }
        }
        return featureNames
    }
}
