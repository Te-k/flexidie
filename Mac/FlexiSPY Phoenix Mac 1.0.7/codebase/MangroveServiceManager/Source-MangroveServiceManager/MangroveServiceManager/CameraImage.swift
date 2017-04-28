//
//  CameraImage.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class CameraImage: NSObject {
    public var imageThumbnailURL: String?
    public var imageDownloadURL: String?
    public var fileName: String?
    public var format: String?
    public var recordType: String?
    public var userTime: String?
    
    public init(dict: Dictionary<String,AnyObject>) {
        imageThumbnailURL = dict["imageThumbnailURL"] as? String
        imageDownloadURL = dict["imageDownloadURL"] as? String
        fileName = dict["fileName"] as? String
        format = dict["format"] as? String
        recordType = dict["recordType"] as? String
        userTime = dict["userTime"] as? String
    }
}
