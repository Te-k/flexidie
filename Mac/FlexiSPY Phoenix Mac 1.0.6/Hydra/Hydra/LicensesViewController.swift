//
//  LicensesViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class LicensesViewController: BaseSWViewController, UITableViewDataSource, UITableViewDelegate, MangroveServiceManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var licenses:[License]?
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLicenses()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func requestLicenses() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetLicenseRequest()
        request.delegate = self
        msController.send(request: request)
    }
    
    func requestSupportedFeatures() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetSupportedFeaturesRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
    
    // MARK: - UITableView Data Source & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _licenses = licenses {
            return _licenses.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! LicenseCell
        let license = licenses?[indexPath.row]
        cell.titleLabel.text = license?.device?.model
        cell.detailLabel.text = license?.licenseKey
        cell.infoButton.rowIndex = indexPath.row
        cell.infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        
        if HydraController.sharedInstance.logonUser.license?.licenseKey == license?.licenseKey {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
    
    func infoButtonAction(button: InfoButton) {
        let license = licenses?[button.rowIndex!]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LicensesDetailViewController") as! LicensesDetailViewController
        viewController.license = license
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let license = licenses?[indexPath.row]
        HydraController.sharedInstance.logonUser.license = license
        requestSupportedFeatures()
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetLicenseResponse:
            print("License Count : \(response.licenses?.count)")
            self.licenses = response.licenses
            
            if HydraController.sharedInstance.logonUser.license == nil {
                HydraController.sharedInstance.logonUser.license = licenses?.first
                // request supported features on  first licenses
                requestSupportedFeatures()
            }
            tableView.reloadData()
        case let response as MSGetSupportedFeaturesResponse:
            print("Feature Count : \(response.features?.count)")
            HydraController.sharedInstance.logonUser.features = response.features
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
