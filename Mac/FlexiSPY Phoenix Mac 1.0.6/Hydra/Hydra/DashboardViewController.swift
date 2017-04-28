//
//  DashboardViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/22/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

enum DashboardDisplayType {
    case group
    case list
}

class DashboardViewController: BaseSWViewController {

    @IBOutlet weak var testView: UIView!
    fileprivate var features: [String]! = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    var licenses:[License]?
    @IBOutlet weak var buttonDisplayTypeGroup: UIButton!
    @IBOutlet weak var buttonDisplayTypeList: UIButton!

    var dashboardDisplayType:DashboardDisplayType = .group
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var rect = testView.frame
        rect.origin.x = 0
        rect.origin.y = 0
        rect.size.width = self.view.frame.width - 44
        testView.frame = rect
        self.navigationController?.toolbar.addSubview(testView)
        self.navigationController?.toolbar.bringSubview(toFront: testView)
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
        
        if let _features = HydraController.sharedInstance.persistedFeaturesWithLogonUser() {
            features = _features
        } else {
            features = HydraController.sharedInstance.supportedFeatureNames()
        }
    }
    
    func requestLicenses() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetLicenseRequest()
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
            
        case let response as MSGetSupportedFeaturesResponse:
            print("Feature Count : \(response.features?.count)")
            HydraController.sharedInstance.logonUser.features = response.features
            
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

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var numItemsPerRow: CGFloat = 0
        var gap: CGFloat = 0
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        if dashboardDisplayType == .group {
            numItemsPerRow = 3
            gap = 10
            cellWidth = collectionView.frame.width / numItemsPerRow - gap - (gap / numItemsPerRow)
            cellHeight = cellWidth
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
        if dashboardDisplayType == .group {
            cellIdentifier = "CellGroup"
        } else {
            cellIdentifier = "CellList"
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! SettingCell
        cell.titlelabel.text = "\(features[indexPath.row])"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = features.remove(at: sourceIndexPath.item)
        features.insert(temp, at: destinationIndexPath.item)
    }
    
}
