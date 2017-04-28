//
//  UserProfileViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class UserProfileViewController: UITableViewController, MangroveServiceManagerDelegate {

    var account:Account?
    @IBOutlet weak var profileNamelabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var locationTimeIntervalLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    @IBAction func closeView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Methods
    func setupUI() {
        profileNamelabel.text = (account?.firstname ?? "" ) + " " + (account?.lastname ?? "")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.allowsSelection = false
    }
    
    func updateUI() {
        deviceNameLabel.text = HydraController.sharedInstance.logonUser.license?.device?.model
        let timeInterval = HydraController.sharedInstance.locationTimeInterval
        locationTimeIntervalLabel.text = "\(timeInterval) S"
    }
    
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetAccountRequest()
        request.JSID = HydraController.sharedInstance.JSID
        request.delegate = self
        msController.send(request: request)
    }
    
    @IBAction func logout(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: HydraContext.HydraLogoutNotification), object: nil)
    }
    
    @IBAction func logoutToInitialState(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "isFirstLogin")
        HydraController.sharedInstance.logonUser = LogonUser()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: HydraContext.HydraLogoutNotification), object: nil)
    }
    
    @IBAction func openBrowser(_ sender: Any) {
        guard let portalUrl = URL(string: MSContext.portalBaseUrl) else {
            return
        }
        UIApplication.shared.openURL(portalUrl)
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetAccountResponse:
            account = response.account
            setupUI()
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //view.contentv = tableView.backgroundColor
        view.tintColor = tableView.backgroundColor
    }
}
