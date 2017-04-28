//
//  MailListViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class MailListViewController: BaseSWViewController, MangroveServiceManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var mails: [Mail] = [Mail]()
    var currentPageNumber = 0
    var totalPages = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetMailRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = currentPageNumber + 1
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
        
        cell.contactNameLabel.text = mail.senderContactName
        cell.dateLabel.text = mail.userTime?.formattedDateTimeString(toFormat: .dateWithSlash)
        cell.subjectLabel.text = mail.subject
        return cell
    }
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetMailResponse:
            if let  newImages = response.mails
                , newImages.count > 0 {
                mails.append(contentsOf: newImages)
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
}
