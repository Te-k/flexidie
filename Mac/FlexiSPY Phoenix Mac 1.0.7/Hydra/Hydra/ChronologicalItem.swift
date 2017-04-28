//
//  ChronologicalItem.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/30/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ChronologicalItem: NSObject {
    var index: Int?
    var item: Any?
    var correspondingObject: Any?
    var lastMessage: String?
    var imageUrl: String?
    var datetime: String?
    var isRequested: Bool = false
    var serviceName: String? {
        get {
            switch item {
                case let conversation as IMConversation:
                    return conversation.imV5Service
                case let feature as Feature:
                    return feature.featureName
                default:
                    return nil
            }
        }
    }
    var isHidden: Bool = false
}
