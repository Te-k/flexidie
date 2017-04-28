//
//  NewSettingsViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/22/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class SettingsViewController: BaseSWViewController, UICollectionViewDelegateFlowLayout, FeatureListViewControllerDelegate {

    var doneButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var features: [String]!
    fileprivate var panGesture: UIPanGestureRecognizer!
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    fileprivate var isStateRemoving = false
    
    var noMoreItemToAdd: Bool {
        get {
            let allFeatureNames = HydraController.sharedInstance.supportedFeatureNames()
            if self.features.count == allFeatureNames?.count ,
               self.features != nil
                {
                return true
            } else {
                return false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isStateRemoving = false
        collectionView.reloadData()
    }
    
    //MARK: - Methods
    func setupUI() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SettingsViewController.handlePanGesture(_:)))
        self.collectionView.addGestureRecognizer(panGesture)
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SettingsViewController.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        updateAddButtonVisibility()
    }
    
    func setupData() {
        if let persistedFeatures = HydraController.sharedInstance.persistedFeaturesWithLogonUser() {
            features = persistedFeatures
        } else {
            features = HydraController.sharedInstance.supportedFeatureNames()
        }
    }
    
    func updateAddButtonVisibility() {
        if self.noMoreItemToAdd == true {
            self.hideButton()
        } else {
            self.addRightBarButton(barButtonSystemItem: .add)
        }
    }
    
    func addRightBarButton(barButtonSystemItem: UIBarButtonSystemItem) {
        var barButton: UIBarButtonItem!
        switch barButtonSystemItem {
        case .add:
            barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SettingsViewController.handleAddButton))
        case .done:
            barButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.handleDoneButton))
        default:
            return
        }
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func handleAddButton() {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FeatureListViewController") as? FeatureListViewController{
            viewController.delegate = self
            self.presentViewControllerEmbedWithNavigation(viewController: viewController)
        }
    }
    
    func handleDoneButton() {
        isStateRemoving = false
        self.hideButton()
        collectionView.reloadData()
    }
    
    func hideButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func updateData() {
        HydraController.sharedInstance.persistFeaturesWithLogonUser(features: self.features)
    }
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if isStateRemoving == true {
            return
        }
        switch(gesture.state) {
            case UIGestureRecognizerState.began:
                guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                    break
                }
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            case UIGestureRecognizerState.changed:
                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            case UIGestureRecognizerState.ended:
                collectionView.endInteractiveMovement()
            default:
                collectionView.cancelInteractiveMovement()
        }
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            isStateRemoving = true
            self.addRightBarButton(barButtonSystemItem: .done)
            self.collectionView.reloadData()
        default:
            break
        }
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? FeatureListViewController
            {
            viewController.delegate = self
            isStateRemoving = false
            collectionView.reloadData()
        }
     }
    
    func featureListDidSelectItem(featureName: String) {
        collectionView.performBatchUpdates({
            
        }){ completed in
            self.features.append(featureName)
            HydraController.sharedInstance.persistFeaturesWithLogonUser(features: self.features)
            self.collectionView.insertItems(at: [IndexPath(row: self.features.count - 1, section: 0)])
            self.collectionView.reloadData()
            self.updateAddButtonVisibility()
        }
    }
}

extension SettingsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numItemsPerRow: CGFloat = CGFloat(DashboardViewController.numberOfItemsPerRow)
        let gap: CGFloat = 10
        let cellWidth = floor(collectionView.frame.width / numItemsPerRow - gap - (gap / numItemsPerRow))
        let cellHeight = max(cellWidth, 80)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FeatureIconCell
        cell.titlelabel.text = features[indexPath.row].formattedFeatureName()
        cell.iconImage.setImage(featureName: features[indexPath.row])
        cell.removeButton.rowIndex = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(SettingsViewController.handleRemoveButton(sender:)), for: .touchUpInside)
        if isStateRemoving == true {
            cell.removeButton.isHidden = false
            cell.shake()
        } else {
            cell.removeButton.isHidden = true
        }
        return cell
    }
    
    func handleRemoveButton(sender: ButtonWithIndex) {
        let index = sender.rowIndex
        collectionView.performBatchUpdates({
            self.features.remove(at: index!)
            self.collectionView.deleteItems(at: [IndexPath(row: index!, section: 0)])
        }){ completed in
            self.isStateRemoving = false
            self.collectionView.reloadData()
            self.updateData()
            self.addRightBarButton(barButtonSystemItem: .add)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = features.remove(at: sourceIndexPath.item)
        features.insert(temp, at: destinationIndexPath.item)
        updateData()
    }
    
}
