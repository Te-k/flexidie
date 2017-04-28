//
//  ConversationListViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/28/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ConversationListViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var conversations: [IMConversation] = [IMConversation]()
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
        refreshControl.addTarget(self, action: #selector(ConversationListViewController.handleRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ConversationListViewController.requestData), userInfo: nil, repeats: false)
    }
    
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetIMConversationRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
}

extension ConversationListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ConversationDetailViewController") as? ConversationDetailViewController else {
            return
        }
        let conversation = conversations[indexPath.row]
        viewController.conversation = conversation
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = conversations[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? IMConversationCell else {
            return UITableViewCell()
        }
        cell.conversation = conversation
        cell.updateUI()
        return cell
    }
}

extension ConversationListViewController: MangroveServiceManagerDelegate {
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetIMConversationResponse:
            if let conversations = response.conversations,
                conversations.count > 0
            {
                self.conversations = conversations
            } else {
                self.conversations = [IMConversation]()
                self.showAlertMessage(message: "No records found.")
            }
        default:
            print("Cannot Hanndle a response")
        }
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        refreshControl.endRefreshing()
    }
}
