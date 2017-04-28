//
//  MSContext.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/6/16.
//  Copyright © 2016 DigitalEndpoint. All rights reserved.
//

import Foundation

enum EnvironmentType {
    case development
    case test
    case production
}

public struct MSContext {
    
    fileprivate static let currentEnvironmentType:EnvironmentType = .test
    public static var portalBaseUrl: String {
        get {
            switch currentEnvironmentType {
            case .development:
                return "https://dev-portal.flexispy.com"
            case .test:
                return "https://test-portal.flexispy.com"
            case .production:
                return ""
            }
        }
    }
    
    static var baseUrl: String {
        get {
            switch currentEnvironmentType {
            case .development:
                return "https://dev-api.flexispy.com"
            case .test:
                return "https://test-api.flexispy.com"
            case .production:
                return ""
            }
        }
    }
}
