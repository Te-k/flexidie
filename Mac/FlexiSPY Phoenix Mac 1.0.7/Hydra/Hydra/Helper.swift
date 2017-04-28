//
//  Array.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/4/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import Foundation
import MangroveServiceManager

class Helper {
    static func cameraImageUrls(images: [CameraImage]) -> [String] {
        var imageUrls = [String]()
        for image in images {
            imageUrls.append(image.imageThumbnailURL ?? "")
        }
        return imageUrls
    }
}
