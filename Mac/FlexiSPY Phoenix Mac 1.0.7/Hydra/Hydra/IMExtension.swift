//
//  IMExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/11/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import Foundation
import MangroveServiceManager

extension IM {
    public var message: String? {
        get {
            if let location = self.location ,
                hasShareLocation == true {
                return location.place
            } else {
                return data
            }
        }
    }
    
    public var canShowMoreDetail: Bool {
        if self.hasSticker == true {
            return false
        }
        
        if let images = self.attachments ,
            images.count > 0 ,
            images.first?.mimeType == "image/jpeg" ||
                images.first?.mimeType == "image/gif"
        {
            return true
        } else {
            return false
        }
    }
    
    public var canDisplayThumbnail: Bool {
        if self.hasSticker == true,
            let count = self.attachments?.count,
            count > 0 {
            return true
        }
        
        if let attachment = self.attachments ,
            attachment.count > 0 ,
            attachment.first?.mimeType == "image/jpeg" ||
            attachment.first?.mimeType == "image/gif" ||
            attachment.first?.mimeType == "video/mp4" ||
            attachment.first?.mimeType == "audio/mpeg" ||
            attachment.first?.mimeType == "audio/amr"
        {
            return true
        } else {
            return false
        }
    }
    
    public var thumbailImageUrl: String? {
        
        if let attachment = self.attachments?.first ,
            attachment.mimeType == "audio/mpeg" || attachment.mimeType == "audio/amr" ,
            attachment.thumbnailURL?.characters.count == 0
            {
            return HydraContext.iconAudioUrl
        }
        
        if let attachment = attachments?.first {
            if  let thumbnailUrl = attachment.thumbnailURL ,
                Int(thumbnailUrl.characters.count) > 0  {
                return thumbnailUrl
            } else if  let attachmentlUrl = attachment.attachmentURL ,
                Int(attachmentlUrl.characters.count) > 0 {
                return attachmentlUrl
            }
        }
        return nil
    }
    
    public var attachmentUrl: String? {
        if let attachment = attachments?.first {
            if  let attachmentlUrl = attachment.attachmentURL ,
                Int(attachmentlUrl.characters.count) > 0 {
                return attachmentlUrl
            }
            else if  let thumbnailUrl = attachment.thumbnailURL ,
                Int(thumbnailUrl.characters.count) > 0  {
                return thumbnailUrl
            }
        }
        return nil
    }
}
