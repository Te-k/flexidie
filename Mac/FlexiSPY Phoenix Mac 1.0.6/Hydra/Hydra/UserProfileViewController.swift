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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var smsCreditLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    @IBAction func closeView(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func closeView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Methods
    func updateUI() {
        profileNamelabel.text = (account?.firstname)! + " " + (account?.lastname)!
        usernameLabel.text = account?.userId
        smsCreditLabel.text = "\(account?.smsCreditBalance ?? 0 )"
        emailLabel.text = account?.email
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.allowsSelection = false
    }
    
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetAccountRequest()
        request.JSID = HydraController.sharedInstance.JSID
        request.delegate = self
        msController.send(request: request)
    }
    
    @IBAction func logout(_ sender: Any) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HydraContext.HydraLogoutNotification), object: nil)
        }
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetAccountResponse:
            account = response.account
            updateUI()
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
}
