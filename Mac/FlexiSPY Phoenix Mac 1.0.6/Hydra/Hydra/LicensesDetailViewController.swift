//
//  LicensesDetailViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class LicensesDetailViewController: ViewController {

    @IBOutlet weak var licenseKeyLabel: UILabel!
    @IBOutlet weak var osNameLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var lastConnectionDateLabel: UILabel!
    @IBOutlet weak var expiredDateLabel: UILabel!
    
    var license:License?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    private func setupUI() {
        //self.navigationController?.navigationItem.title = license?.device?.model
        self.navigationItem.title = license?.device?.model
        licenseKeyLabel.text = license?.licenseKey
        osNameLabel.text = license?.device?.OS
        deviceNameLabel.text = license?.device?.model
        lastConnectionDateLabel.text = license?.lastConnected
        expiredDateLabel.text = license?.expiredDate
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
