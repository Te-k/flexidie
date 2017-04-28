//
//  LoginViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class LoginViewController: ViewController, MangroveServiceManagerDelegate {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addObserver()
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(logoutSignalReceived), name: NSNotification.Name(rawValue: HydraContext.HydraLogoutNotification), object: nil)
    }
    
    func clearAllCookies() {
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
    }
    
    func requestLogout() {
        let msController = HydraController.sharedInstance.msController
        let request = MSLogoutRequest()
        request.JSID = HydraController.sharedInstance.JSID
        request.delegate = self
        msController.send(request: request)
    }
    
    func logoutSignalReceived(notifiaction: Notification) {
        let _ = navigationController?.popToRootViewController(animated: true)
        requestLogout()
    }
    
    // MARK: - IBActions
    @IBAction func login(_ sender: Any) {
        let username = usernameTextfield.text
        let password = passwordTextfield.text
        
        let msController = HydraController.sharedInstance.msController
        let request = MSAuthenticationRequest()
        request.username = username
        request.password = password
        request.delegate = self
        msController.send(request: request)
        loginButton.isEnabled = false
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        loginButton.isEnabled = true
        switch response {
            case let response as MSAuthenticationResponse:
                HydraController.sharedInstance.JSID = response.JSID
                HydraController.sharedInstance.logonUser.username = usernameTextfield.text
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController")
                self.navigationController?.pushViewController(viewController!, animated: true)
            case _ as MSLogoutResponse:
                clearAllCookies()
            default:
                print("Cannot Hanndle a response")
        }
    }
    
    func requestError(error: Error?) {
        loginButton.isEnabled = true
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

}
