//
//  MailListViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class MailListViewController: ViewController, MangroveServiceManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var mails: [Mail] = [Mail]()
    var currentPageNumber = 0
    var totalPages = 0
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    func setupUI() {
        refreshControl.addTarget(self, action: #selector(MailListViewController.handleRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MailListViewController.requestData), userInfo: nil, repeats: false)
    }
    
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetMailRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = currentPageNumber + 1
        request.pageSize = 40
        request.delegate = self
        msController.send(request: request)
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mails.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "MailDetailViewController") as? MailDetailViewController {
            viewController.mail = mails[indexPath.row]
            let _ = navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier") as? MailCell else {
            return UITableViewCell()
        }
        
        let mail = mails[indexPath.row]
        cell.contactNameLabel.text = mail.senderDisplayName
        cell.dateLabel.text = mail.userTime?.formattedDateTimeString(toFormat: .dateWithSlash)
        cell.subjectLabel.text = mail.subject
        return cell
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetMailResponse:
            if let  mails = response.mails
                , mails.count > 0 {
                self.mails = mails
                //currentPageNumber = response.pageNumber ?? 1
                tableView.reloadData()
            } else {
                self.showAlertMessage(message: "No records found.")
            }
            totalPages = response.totalPages ?? 0
        default:
            print("Cannot Hanndle a response")
        }
        self.refreshControl.endRefreshing()
    }
    
    override func requestError(error: Error?) {
        self.refreshControl.endRefreshing()
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
