//
//  DashboardViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/22/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

enum DashboardDisplayType: Int {
    case group
    case list
}

class DashboardViewController: ViewController {
    fileprivate var features: [String]! = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    var licenses:[License]?
    @IBOutlet weak var buttonDisplayTypeGroup: UIButton!
    @IBOutlet weak var buttonDisplayTypeList: UIButton!
    var dashboardDisplayType:DashboardDisplayType = .group
    
    static var numberOfItemsPerRow: Int {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 4
        } else {
            return 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupData()
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Methods
    func setupData() {
        if  HydraController.sharedInstance.logonUser.license == nil {
            self.requestLicenses()
        }
        
        if HydraController.sharedInstance.logonUser.license?.device != nil {
            self.requestNewRecords()
        }
        
        if let _features = HydraController.sharedInstance.persistedFeaturesWithLogonUser() {
            features = _features
        } else {
            features = HydraController.sharedInstance.supportedFeatureNames()
        }
    }
    
    func viewController(_ viewControllerIdentifier:String!) -> UIViewController? {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: viewControllerIdentifier) else {
            return nil
        }
        return viewController
    }
    
    func requestLicenses() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetLicenseRequest()
        request.delegate = self
        msController.send(request: request)
    }
    
    func requestNewRecords() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetNewRecordsRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
    
    func requestSupportedFeatures() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetSupportedFeaturesRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
    
    @IBAction func setDisplayType(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }

        var willChangedTo:DashboardDisplayType!
        if button == buttonDisplayTypeList {
            willChangedTo = .list
        }
        else {
            willChangedTo = .group
        }
        
        if willChangedTo == dashboardDisplayType {
            return
        }else{
            dashboardDisplayType = willChangedTo
            collectionView.performBatchUpdates({
                self.collectionView.reloadData()
            }){ completed in
                self.collectionView.reloadData()
            }
        }
    }
}

extension DashboardViewController: MangroveServiceManagerDelegate {
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetLicenseResponse:
            print("License Count : \(response.licenses?.count)")
            self.licenses = response.licenses
            
            if HydraController.sharedInstance.logonUser.license == nil {
                HydraController.sharedInstance.logonUser.license = licenses?.first
                // request supported features on  first licenses
                requestSupportedFeatures()
            }
            requestNewRecords()
        case let response as MSGetSupportedFeaturesResponse:
            print("Feature Count : \(response.features?.count)")
            HydraController.sharedInstance.logonUser.features = response.features
            self.setupData()
            self.collectionView.reloadData()
        case let response as MSGetNewRecordsResponse:
            print("New Record Count : \(response.newRecords?.count)")
            HydraController.sharedInstance.logonUser.newRecords = response.newRecords
            self.collectionView.reloadData()
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    override func requestError(error: Error?) {
        super.requestError(error: error)
        self.showAlertMessage(message: error.debugDescription)
    }
}

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let featureName = features[indexPath.row]
        var viewController: UIViewController?
        var viewIdentifier = ""
        switch featureName {
        case "Location":
            viewIdentifier = "LocationViewController"
        case "Call":
            viewIdentifier = "CallLogViewController"
        case "AddressBook":
            viewIdentifier = "AddressBookViewController"
        case "SMS":
            viewIdentifier = "SMSListViewController"
        case "CameraImage":
            viewIdentifier = "CameraImageViewController"
        case "Email":
            viewIdentifier = "MailListViewController"
        case "IMs":
            viewIdentifier = "ConversationListViewController"
        default:
            return
        }
        viewController = self.storyboard?.instantiateViewController(withIdentifier: viewIdentifier)
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var numItemsPerRow: CGFloat = CGFloat(DashboardViewController.numberOfItemsPerRow)
        var gap: CGFloat = 0
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        if dashboardDisplayType == .group {
            gap = 10
            cellWidth = floor(collectionView.frame.width / numItemsPerRow - gap - (gap / numItemsPerRow))
            cellHeight = max(cellWidth, 80)
        } else {
            numItemsPerRow = 1
            cellHeight = 50
            gap = 1
            cellWidth = collectionView.frame.width / numItemsPerRow
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier: String!
        let featureName = features[indexPath.row]
        if dashboardDisplayType == .group {
            cellIdentifier = "CellGroup"
        } else {
            cellIdentifier = "CellList"
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FeatureIconCell
        cell.featureName = featureName
        cell.updateUI()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = features.remove(at: sourceIndexPath.item)
        features.insert(temp, at: destinationIndexPath.item)
    }
    
}
