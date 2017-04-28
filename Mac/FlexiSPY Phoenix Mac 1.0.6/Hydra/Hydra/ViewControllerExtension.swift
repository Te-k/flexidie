//
//  ViewControllerExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation

extension UIViewController {
    func showLoadingView() {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WaitingViewController") else {
            return
        }
        self.present(viewController, animated: false, completion: nil)
    }
    
    func hideLoadingView() {
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                presentedViewController.dismiss(animated: false, completion: nil)
            }
        }
    }
}
