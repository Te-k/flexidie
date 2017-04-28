//
//  LicensesViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ChooseDeviceViewController: ViewController, UITableViewDataSource, UITableViewDelegate, MangroveServiceManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var licenses:[License]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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
    
    func setupUI() {
        self.navigationController?.isNavigationBarHidden = false
        
        if HydraController.sharedInstance.isFirstLogin == true {
            self.navigationItem.hidesBackButton = true
        }
    }
    
    func addNextbutton() {
        let nextButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ChooseDeviceViewController.goNext))
        self.navigationItem.rightBarButtonItem = nextButton
    }
    
    func goNext() {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func requestSupportedFeatures() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetSupportedFeaturesRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
    
    func sendChangeDeviceNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: HydraContext.HydraChangeDeviceNotification), object: nil)
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
        cell.detailLabel.text = license?.expiredDate?.formattedDateTimeString(toFormat: .dateWithSlash)
        if HydraController.sharedInstance.logonUser.license?.licenseKey == license?.licenseKey {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
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
        if license?.licenseKey == HydraController.sharedInstance.logonUser.license?.licenseKey {
            return
        }
        HydraController.sharedInstance.logonUser.license = license
        tableView.reloadData()
        requestSupportedFeatures()
        if HydraController.sharedInstance.isFirstLogin == true {
            addNextbutton()
        } else {
            sendChangeDeviceNotification()
        }
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetLicenseResponse:
            print("License Count : \(response.licenses?.count)")
            self.licenses = response.licenses
            
            if HydraController.sharedInstance.logonUser.license == nil ,
               HydraController.sharedInstance.isFirstLogin == false
                {
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
    
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
