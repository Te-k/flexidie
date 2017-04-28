//
//  UIImageViewExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation
import Alamofire
extension UIImageView {
    func setImage(url: URL) {
        Alamofire.request(url).responseData(completionHandler: { response in
            if let data = response.data ,
                let image = UIImage(data: data) {
                self.image = image
            }
        })
    }
}
