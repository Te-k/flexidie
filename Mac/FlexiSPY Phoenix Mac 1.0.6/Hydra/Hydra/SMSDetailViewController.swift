//
//  SMSDetailViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/19/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class SMSDetailViewController: ViewController, MangroveServiceManagerDelegate, SWRevealViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    var groupedSMS: GroupedSMS?
    var dataArray = [SMS]()
    var isRequestingData = false
    var currentPageNumber = 0
    var totalPages = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func setupUI() {
        self.tableView.allowsSelection = false
        self.navigationItem.title = groupedSMS?.senderName
        tableView.estimatedRowHeight = 34
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
        requestData()
    }
    
    func requestData() {
        isRequestingData = true
        let msController = HydraController.sharedInstance.msController
        let request = MSGetSMSRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = currentPageNumber + 1
        request.grouped = false
        request.contactName = groupedSMS?.senderName
        request.senderNumber = groupedSMS?.senderNumber
        request.delegate = self
        msController.send(request: request)
    }
    
    // MARK: - UITableView Data Source & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataItem = dataArray[indexPath.row]
        let cellIdentifier = dataItem.recordDirection == "In" ? "CellIdentifier_DirectionIn" : "CellIdentifier_DirectionOut"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SMSCell else {
            return UITableViewCell()
        }
        cell.messageLabel.text = dataItem.smsData
        cell.datetimeLabel.text = dataItem.userTime?.formattedDateTimeString(toFormat: .dateTimeSMSCell)
        cell.messageLabel.preferredMaxLayoutWidth = 180
        return cell
    }
    
    // MARK: - MangroveServiceManagerDelegate
    
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        isRequestingData = false
        switch response {
        case let response as MSGetSMSResponse:
            if let newItems = response.smses
                , newItems.count > 0 {
                dataArray.append(contentsOf: newItems)
                currentPageNumber = response.pageNumber ?? 1
                tableView.reloadData()
            }
            totalPages = response.totalPages ?? 0
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: - RevealControllerDelegate
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        
        switch position {
        case .right:
            tableView.isUserInteractionEnabled = false
        case .left:
            tableView.isUserInteractionEnabled = true
        default:
            print("Default")
        }
    }
    // Tableview Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
            // start request more data
            if isRequestingData == false , currentPageNumber < totalPages   {
                requestData()
            }
        }
    }
    
}
