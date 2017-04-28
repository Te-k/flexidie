//
//  TabbarViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/29/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class HydraTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
    }
    
    deinit {
        removeObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeDeviceNotificationReceived), name: NSNotification.Name(rawValue: HydraContext.HydraChangeDeviceNotification), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: HydraContext.HydraChangeDeviceNotification))
    }

    func changeDeviceNotificationReceived(notifiaction: Notification) {
        popToRootViewController(tabIndex: 0)
        popToRootViewController(tabIndex: 1)
    }
    
    func popToRootViewController(tabIndex: Int) {
        if let navigationViewController = self.viewControllers?[tabIndex] as? UINavigationController {
            navigationViewController.popToRootViewController(animated: false)
        }
    }
}
