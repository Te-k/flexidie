//
//  ViewController.swift
//  Hydra
//
//  Created by Makara Khloth on 12/8/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestError(error: Error?) {
        // Do something to handle error 
        if let _error = error,
           _error._code == 401 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HydraContext.HydraLogoutNotification), object: nil)
        }
    }
}
