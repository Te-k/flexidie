//
//  ConversationDetailViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ConversationDetailViewController: ViewController {
    
    var instantMessages: [IM] = [IM]()
    @IBOutlet weak var tableView: UITableView!
    var conversation: IMConversation?
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
    
    //MARK: - Methods
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetIMRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.conversationId = conversation?.conversationId
        request.delegate = self
        msController.send(request: request)
    }
    
    func setupUI() {
        self.navigationItem.title = conversation?.conversationName
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: #selector(ConversationDetailViewController.handleRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ConversationDetailViewController.requestData), userInfo: nil, repeats: false)
    }
}

extension ConversationDetailViewController: MangroveServiceManagerDelegate {
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetIMResponse:
            if let imRecords = response.records,
                imRecords.count > 0
            {
                self.instantMessages = imRecords
            } else {
                self.instantMessages = [IM]()
                self.showAlertMessage(message: "No records found.")
            }
        default:
            print("Cannot Hanndle a response")
        }
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        refreshControl.endRefreshing()
    }
}

extension ConversationDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instantMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instantMessage = instantMessages[indexPath.row]
        guard let recordDirection = instantMessage.recordDirection else {
            return UITableViewCell()
        }
        var cell:IMCell?
        var cell_identifier = ""
        switch recordDirection {
        case "In":
            cell_identifier = "Cell_In"
        case "Out":
            cell_identifier = "Cell_Out"
        default:
            return UITableViewCell()
        }
        
        if instantMessage.canDisplayThumbnail == true {
            cell_identifier.append("_Image")
        }
        cell = tableView.dequeueReusableCell(withIdentifier: cell_identifier) as? IMCell
        cell?.delegate = self
        cell?.instantMessage = instantMessage
        cell?.updateUI()
        return cell ?? UITableViewCell()
    }
}

extension ConversationDetailViewController: IMCellDelegate {
    func imCellDidTapImage(imageUrl: String) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ImagePopupViewController") as? ImagePopupViewController {
            viewController.imageUrls = [imageUrl]
            viewController.currentPage = 0
            let navVC = UINavigationController(rootViewController: viewController)
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    func imCellDidTapLabel(location: IMLocation) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController {
            let _location = Location()
            _location.latitude = location.latitude
            _location.longitude = location.longitude
            _location.cellName = location.place
            _location.horizontalAccuracy = location.horAccuracy
            viewController.location = _location
            viewController.isModeButtonsHidden = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
