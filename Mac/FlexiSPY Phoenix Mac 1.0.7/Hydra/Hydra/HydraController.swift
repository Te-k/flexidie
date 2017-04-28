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
    var locationTimeInterval: Int = 5
    static let sharedInstance = HydraController()
    var logonUser: LogonUser = LogonUser()
    var isFirstLogin: Bool {
        get {
            let hasValue = UserDefaults.standard.object(forKey: "isFirstLogin") as? Bool
            return hasValue != nil ? false : true
        }
        set {
            if newValue == false {
                UserDefaults.standard.set(newValue, forKey: "isFirstLogin")
            }
        }
    }
    
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
    
    func supportedFeatures() -> [Feature] {
        let allFeatures = HydraController.sharedInstance.logonUser.features ?? [Feature]()
        var supportedFeatures = [Feature]()
        for feature in allFeatures {
            let availableFeatures = HydraContext.AvailableFeatures
            if let _featureName = feature.featureName
                , availableFeatures.contains(_featureName)
            {
                supportedFeatures.append(feature)
            }
        }
        return supportedFeatures
    }
    
    func supportedFeaturesWithNoExcludedItem() -> [Feature] {
        let allFeatures = supportedFeatures()
        var featuresWithNoExcludedItem = [Feature]()
        let excludedFeatureNames = HydraContext.ExcludedChronologicalFeatures
        for feature in allFeatures {
            if excludedFeatureNames.contains(feature.featureName ?? "") == false {
                featuresWithNoExcludedItem.append(feature)
            }
        }
        return featuresWithNoExcludedItem
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

        // check if IM Services available
        let imServices = HydraContext.IMServices
        for feature in features {
            if let featureName = feature.featureName ,
                imServices.contains(featureName) {
                featureNames.append(HydraContext.IMFeature)
                break
            }
        }
        
        return featureNames
    }
    
}
