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
    @IBOutlet weak var loginbox: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addObserver()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(logoutNotificationReceived), name: NSNotification.Name(rawValue: HydraContext.HydraLogoutNotification), object: nil)
    }
    
    func setupUI() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.backgroundImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundImageView.addSubview(blurEffectView)
        view.bringSubview(toFront: loginbox)

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
    
    func logoutNotificationReceived(notifiaction: Notification) {
        let _ = navigationController?.popToRootViewController(animated: true)
        requestLogout()
    }
    
    func gotoDashboard() {
        if let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "HydraTabbarController") as? HydraTabbarController {
            self.navigationController?.pushViewController(tabbarController, animated: true)
        }
    }
    
    func gotoChooseDevice() {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseDeviceViewController") as? ChooseDeviceViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
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
        //self.showLoadingView()
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        loginButton.isEnabled = true
        switch response {
            case let response as MSAuthenticationResponse:
                HydraController.sharedInstance.JSID = response.JSID
                HydraController.sharedInstance.logonUser.username = usernameTextfield.text
                if HydraController.sharedInstance.isFirstLogin == true {
                    gotoChooseDevice()
                } else {
                    gotoDashboard()
                }
            case _ as MSLogoutResponse:
                clearAllCookies()
            default:
                print("Cannot Hanndle a response")
        }
        //self.hideLoadingView()
    }
    
    override func requestError(error: Error?) {
        loginButton.isEnabled = true
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        //self.hideLoadingView()
    }

}
