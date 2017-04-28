//
//  WelcomeViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/12/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import UIKit

class WelcomeViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - Methods
    
    func setupUI() {
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func gotoDashboard() {
        if let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "HydraTabbarController") as? HydraTabbarController {
            HydraController.sharedInstance.isFirstLogin = false
            self.navigationController?.pushViewController(tabbarController, animated: true)
        }
    }
}
