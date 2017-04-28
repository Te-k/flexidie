//
//  ViewController.swift
//  TestApp
//
//  Created by Chanin Nokpet on 12/7/16.
//  Copyright © 2016 Digital Endpoint. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ViewController: UIViewController, MangroveServiceManagerDelegate {

    @IBOutlet weak var timerLabel: UILabel!
    var timerCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doTest(_ sender: Any) {
        self.testAuthentication()
    }
    
    func setupTimer() {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    func updateTimerLabel() {
        timerCount += 1
        timerLabel.text = "\(timerCount)"
    }
    
    func testAuthentication() {
        let msController = MSController()
        let request = MSAuthenticationRequest()
        request.password = "password"
        request.username = "devlegacy"
        request.delegate = self
        msController.send(request: request)
    }
    
    func testGetLicense(jsid: String) {
        let msController = MSController()
        let request = MSGetLicenseRequest()
        request.JSID = jsid
        request.delegate = self
        msController.send(request: request)
    }
    
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSAuthenticationResponse:
            print("JSID : \(response.JSID)")
            self.testGetLicense(jsid: response.JSID! )
        case let response as MSGetLicenseResponse:
            print("License Count : \(response.licenses?.count)")
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    func requestError(error: Error?) {
        print("Error: \(error?.localizedDescription)")
    }
}

