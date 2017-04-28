//
//  DevicesViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class DeviceDetailViewController: BaseSWTableTableViewController {

    @IBOutlet weak var productIdLabel: UILabel!
    @IBOutlet weak var productVersionlabel: UILabel!
    @IBOutlet weak var customerIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Methods
    func updateUI() {
        self.navigationItem.title = HydraController.sharedInstance.logonUser.license?.device?.model
        let currentLicense = HydraController.sharedInstance.logonUser.license
        productIdLabel.text = currentLicense?.product?.ID
        productVersionlabel.text = currentLicense?.product?.version
        customerIdLabel.text = currentLicense?.customerId
    }
}
