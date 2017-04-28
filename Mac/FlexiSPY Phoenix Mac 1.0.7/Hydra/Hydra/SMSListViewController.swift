//
//  SMSListViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/16/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class SMSListViewController: ViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataArray = [GroupedSMS]()
    var isRequestingData = false
    var currentPageNumber = 0
    var totalPages = 0
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func requestData() {
        isRequestingData = true
        let msController = HydraController.sharedInstance.msController
        let request = MSGetSMSRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = currentPageNumber + 1
        request.grouped = true
        request.delegate = self
        msController.send(request: request)
    }
    
    func setupUI() {
        refreshControl.addTarget(self, action: #selector(SMSListViewController.handleRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SMSListViewController.requestData), userInfo: nil, repeats: false)
    }
}

extension SMSListViewController: MangroveServiceManagerDelegate {
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        isRequestingData = false
        switch response {
        case let response as MSGetSMSResponse:
            if let newItems = response.smses as? [GroupedSMS]
                , newItems.count > 0 {
                dataArray = newItems
                //currentPageNumber = response.pageNumber ?? 1
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

extension SMSListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? SMSListCell else {
            return UITableViewCell()
        }
        
        let dataItem = dataArray[indexPath.row]
        cell.titleLabel.text =  "\(dataItem.senderName ?? "") (\(dataItem.count ?? 0))"
        cell.messageLabel.text = dataItem.recentMessages
        cell.dateLabel.text = dataItem.userTime?.formattedDateTimeString(toFormat: .dateWithSlash)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupedSMS = dataArray[indexPath.row]
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SMSDetailViewController") as? SMSDetailViewController else {
            return
        }
        
        viewController.groupedSMS = groupedSMS
        navigationController?.pushViewController(viewController, animated: true)
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
