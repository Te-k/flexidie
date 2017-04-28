//
//  MSGetCameraImageRequest.swift
//  MangroveServiceManager
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit

public class MSGetCameraImageRequest: MSRequest {
    public var deviceId: Int?
    public var recordType: String? = "CameraImage"
    public var pageSize = 20
    public var pageNumber = 1
    public var grouped = false
    public var orderBy = "desc"
    public var sortBy = "userTime"
}
