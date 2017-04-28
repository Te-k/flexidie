//
//  UIImageViewExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation
import Alamofire
import AVFoundation

extension UIImageView {
    func setImage(url: URL) {
        Alamofire.request(url).responseData(completionHandler: { response in
            if let data = response.data ,
                let image = UIImage(data: data) {
                self.image = image
            }
        })
    }
    
    func setImage(imServiceName: String) {
        var imageName = ""
        switch imServiceName {
        case "Hangout":
            imageName = "icon-hangout"
        case "HikeMessenger":
            imageName = "icon-hike"
        case "LINE":
            imageName = "icon-line"
        case "Snapchat":
            imageName = "icon-snapchat"
        case "Tinder":
            imageName = "icon-tinder"
        case "KIKMessenger":
            imageName = "icon-kik"
        case "Telegram":
            imageName = "icon-telegram"
        case "FaceBook":
            imageName = "icon-facebook"
        case "Skype":
            imageName = "icon-skype"
        case "WhatsApp":
            imageName = "icon-whatsapp"
        case "iMessage":
            imageName = "icon-imessage"
        default:
            imageName = "icon-default"
        }
        self.image = UIImage(named: imageName)
    }
    
    func setImage(featureName: String) {
        let prefix = "feature-"
        var imageName = ""
        switch featureName {
        case "SMS":
            imageName = "SMS"
        case "Email":
            imageName = "Email"
        case "CameraImage":
            imageName = "Image"
        case "Location":
            imageName = "Location"
        case "AddressBook":
            imageName = "AddressBook"
        case "IMs":
            imageName = "IMs"
        case "Call":
            imageName = "Call"
        default:
            imageName = "icon-default"
        }
        imageName = prefix + imageName
        self.image = UIImage(named: imageName)
    }
    
    func setImage(videoUrl: URL) {
        do {
            let asset = AVURLAsset(url: videoUrl , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            self.image = thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
    }
}
