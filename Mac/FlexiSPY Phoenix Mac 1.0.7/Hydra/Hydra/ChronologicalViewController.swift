//
//  ChronologicalViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/27/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ChronologicalViewController: ViewController {
    var chronologicalItems: [ChronologicalItem] = [ChronologicalItem]()
    var conversations: [IMConversation] = [IMConversation]()
    var changeOrderButton: UIButton!
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        changeOrderButton.isHidden = false
        requestConversations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        changeOrderButton.isHidden = true
    }
    
    //MARK: - Methods
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ChronologicalViewController.requestConversations), userInfo: nil, repeats: false)
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeDeviceNotificationReceived), name: NSNotification.Name(rawValue: HydraContext.HydraChangeDeviceNotification), object: nil)
    }
    
    func changeDeviceNotificationReceived(notifiaction: Notification) {
        requestConversations()
    }
    
    func requestConversations() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetIMConversationRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
    
    func requestLastRecord(chronologicalItem: ChronologicalItem) {
        let controller = ChronologicalController()
        controller.delegate = self
        controller.chronologicalItem = chronologicalItem
        controller.requestLastRecord()
    }
    
    func updateData() {
        var newChronologicalItems = [ChronologicalItem]()
        //chronologicalItems.removeAll()
        let features = HydraController.sharedInstance.supportedFeaturesWithNoExcludedItem()
        
        // for IMConversation
        for conversation in conversations {
            let item = ChronologicalItem()
            item.item = conversation
            item.isHidden = self.isItemHidden(serviceName: conversation.imV5Service ?? "")
            newChronologicalItems.append(item)
        }
        
        // for Supported Features
        for feature in features {
            let item = ChronologicalItem()
            item.item = feature
            item.isHidden = self.isItemHidden(serviceName: feature.featureName ?? "")
            newChronologicalItems.append(item)
        }
        self.chronologicalItems = newChronologicalItems
    }
    
    func isItemHidden(serviceName: String) -> Bool {
        for item in self.chronologicalItems {
            if serviceName == item.serviceName {
                return item.isHidden
            }
        }
        return false
    }
    
    
    func setupUI() {
        if changeOrderButton == nil {
            let button = UIButton(frame: CGRect.zero)
            button.setImage(UIImage(named: "arrow-down"), for: .normal)
            button.frame.size.width = 30
            button.frame.size.height = 30
            button.center = navigationController?.navigationBar.center ?? CGPoint.zero
            button.frame.origin.y -= 5
            button.addTarget(self, action: #selector(ChronologicalViewController.handleButtonTabbed) , for: .touchUpInside)
            changeOrderButton = button
            
            let tabGesture = UITapGestureRecognizer()
            tabGesture.addTarget(self, action: #selector(ChronologicalViewController.handleButtonTabbed))
            
            if let navbarItem = self.navigationController?.navigationBar.subviews[1] {
                navbarItem.isUserInteractionEnabled = true
                navbarItem.gestureRecognizers = [tabGesture]
            }
            navigationController?.navigationBar.addSubview(changeOrderButton)
        }
        refreshControl.addTarget(self, action: #selector(ChronologicalViewController.handleRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func handleButtonTabbed() {
        let deviceType = UIDevice.current.userInterfaceIdiom
        switch deviceType {
            case .pad:
                break
            case .phone:
                presentActionSheet()
            default:
                break
        }
    }
    
    func presentActionSheet() {
        let alertView = UIAlertController(title: "Change Order", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alertView.addAction(UIAlertAction(title: "Time received", style: UIAlertActionStyle.default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Unread messages", style: UIAlertActionStyle.default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? EditFilterChronologicalViewController {
            viewController.chronologicalItems = chronologicalItems
            viewController.delegate = self
        }
    }
}

extension ChronologicalViewController: EditFilterViewControllerDelegate {
    func didFinishUpdateFilter(filteredChronologicalItems: [ChronologicalItem]) {
        self.chronologicalItems = filteredChronologicalItems
        tableView.reloadData()
    }
}

extension ChronologicalViewController: MangroveServiceManagerDelegate {
    
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetIMConversationResponse:
            if let conversations = response.conversations,
                    conversations.count > 0
                {
                self.conversations = conversations
                self.updateData()
                tableView.reloadData()
            } else {
                self.conversations = [IMConversation]()
                self.showAlertMessage(message: "No records found.")
            }
        default:
            print("Cannot Hanndle a response")
        }
        self.refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        self.refreshControl.endRefreshing()
    }
}

extension ChronologicalViewController: ChronologicalControllerDelegate {
    func chronologicalControllerRequestCompleted(itemWithLastRecord: ChronologicalItem) {
        guard let index = itemWithLastRecord.index else {
            return
        }
        
        chronologicalItems[index] = itemWithLastRecord
        tableView.reloadRows(at: [IndexPath(row:index, section:0)], with: .fade)
    }
    
    func chronologicalControllerRequestError(error: Error) {
        self.showAlertMessage(message: error.localizedDescription)
    }
}

extension ChronologicalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chronologicalItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chronologicalItem = chronologicalItems[indexPath.row]
        var viewController: UIViewController?
        switch chronologicalItem.item {
        case let conversation as IMConversation:
            guard let _viewController = self.storyboard?.instantiateViewController(withIdentifier: "ConversationDetailViewController") as? ConversationDetailViewController else {
                return
            }
            _viewController.conversation = conversation
            viewController = _viewController
        case let feature as Feature:
            let featureName = feature.featureName ?? ""
            switch featureName {
            case "Location":
                guard let _viewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController else {
                    return
                }
                _viewController.location = chronologicalItem.correspondingObject as? Location
                _viewController.isModeButtonsHidden = true
                viewController = _viewController
            case "Call":
                guard let _viewController = self.storyboard?.instantiateViewController(withIdentifier: "CallLogDetailViewController") as? CallLogDetailViewController else {
                    return
                }
                _viewController.callLog = chronologicalItem.correspondingObject as? CallLog
                viewController = _viewController
            case "AddressBook":
                guard let _viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController else {
                    return
                }
                _viewController.contact = chronologicalItem.correspondingObject as? Contact
                viewController = _viewController
            case "SMS":
                guard let _viewController = self.storyboard?.instantiateViewController(withIdentifier: "SMSDetailViewController") as? SMSDetailViewController else {
                    return
                }
                _viewController.groupedSMS = chronologicalItem.correspondingObject as? GroupedSMS
                viewController = _viewController
            case "CameraImage":
                guard let _viewController = self.storyboard?.instantiateViewController(withIdentifier: "ImagePopupViewController") as? ImagePopupViewController else {
                    return
                }
                if let image = chronologicalItem.correspondingObject as? CameraImage {
                    _viewController.imageUrls = Helper.cameraImageUrls(images: [image])
                }
                self.presentViewControllerEmbedWithNavigation(viewController: _viewController)
                return
            case "Email":
                guard let _viewController = self.storyboard?.instantiateViewController(withIdentifier: "MailDetailViewController") as? MailDetailViewController else {
                    return
                }
                _viewController.mail = chronologicalItem.correspondingObject as? Mail
                viewController = _viewController
            default:
                break
            }
    
        default:
            return
        }
        
        if let viewControllerPush = viewController {
            self.navigationController?.pushViewController(viewControllerPush, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chronologicalItem = chronologicalItems[indexPath.row]
        
        if chronologicalItem.isHidden == true {
            return 0
        }
        else {
            return 102
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chronologicalItem = chronologicalItems[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellText") as? ChronologicalCell else {
                            return UITableViewCell()
                        }
        chronologicalItem.index = indexPath.row
        
        if chronologicalItem.isRequested == false {
            requestLastRecord(chronologicalItem: chronologicalItem)
        }
        cell.chronologicalItem = chronologicalItem
        
        if chronologicalItem.isHidden == false {
            cell.updateUI()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Commit Delete")
        }
    }
}
