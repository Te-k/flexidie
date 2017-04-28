//
//  CallLogViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/14/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class CallLogViewController: ViewController {

    @IBOutlet weak var tableView: UITableView!
    var callLogs = [CallLog]()
    var isRequestingData = false
    var currentPageNumber = 0
    var totalPages = 0
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func setupUI() {
        self.tableView.allowsSelection = false
        self.navigationItem.title = "Call Log"
        refreshControl.addTarget(self, action: #selector(CallLogViewController.handleRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func requestData() {
        isRequestingData = true
        let msController = HydraController.sharedInstance.msController
        let request = MSGetCallLogRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = currentPageNumber + 1
        request.delegate = self
        msController.send(request: request)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CallLogViewController.requestData), userInfo: nil, repeats: false)
    }
}

extension CallLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? CallLogCell else {
            return UITableViewCell()
        }
        
        let callLog = callLogs[indexPath.row]
        cell.contactNameLabel.text = callLog.contactName
        cell.datetimeLabel.text = callLog.userTime?.formattedDateTimeString(toFormat: .dateWithSlash)

        let imageName = callLog.recordDirection == "Out" ? "phone-call-out" : "phone-call-in"
        let directionImage = UIImage(named: imageName)
        cell.callDirectionImageView.image = directionImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CallLogDetailViewController") as? CallLogDetailViewController
            else {
                return
        }
        let callLog = callLogs[indexPath.row]
        viewController.callLog = callLog
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    // Tableview Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
//            // start request more data
//            if isRequestingData == false , currentPageNumber < totalPages   {
//                requestData()
//            }
//        }
//    }
}

extension CallLogViewController: MangroveServiceManagerDelegate {
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        isRequestingData = false
        switch response {
        case let response as MSGetCallLogResponse:
            if let  callLogs = response.callLogs
                , callLogs.count > 0 {
                self.callLogs = callLogs
                tableView.reloadData()
            } else {
                self.showAlertMessage(message: "No records found.")
            }
            totalPages = response.totalPages ?? 0
        default:
            print("Cannot Hanndle a response")
        }
        refreshControl.endRefreshing()
    }
    
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        refreshControl.endRefreshing()
    }
}
