//
//  NewSettingsViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/22/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class SettingsViewController: BaseSWViewController, UICollectionViewDelegateFlowLayout, FeatureListViewControllerDelegate {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var features: [String]!
    fileprivate var panGesture: UIPanGestureRecognizer!
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    fileprivate var isStateRemoving = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        persistFeatures()    }
    
    //MARK: - Methods
    func setupUI() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SettingsViewController.handlePanGesture(_:)))
        self.collectionView.addGestureRecognizer(panGesture)
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SettingsViewController.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        doneButton.target = self
        doneButton.action = #selector(SettingsViewController.handleDone)
        hideButton(doneButton)
    }
    
    func setupData() {
        if let persistedFeatures = HydraController.sharedInstance.persistedFeaturesWithLogonUser() {
            features = persistedFeatures
        } else {
            features = HydraController.sharedInstance.supportedFeatureNames()
        }
    }
    
    func persistFeatures() {
        
    }
    
    func showButton(_ button:UIBarButtonItem) {
        button.isEnabled = true
        button.tintColor = self.view.tintColor
    }
    
    func hideButton(_ button:UIBarButtonItem) {
        button.isEnabled = false
        button.tintColor = UIColor.clear
    }
    
    func handleDone() {
        isStateRemoving = false
        hideButton(doneButton)
        showButton(addButton)
        collectionView.reloadData()
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
        hideButton(addButton)
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            isStateRemoving = true
            showButton(doneButton)
            self.collectionView.reloadData()
        default:
            break
        }
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? FeatureListViewController {
            viewController.delegate = self
        }
     }
    
    func featureListDidSelectItem(featureName: String) {
        collectionView.performBatchUpdates({
            
        }){ completed in
            self.features.append(featureName)
            self.collectionView.insertItems(at: [IndexPath(row: self.features.count - 1, section: 0)])
            self.collectionView.reloadData()
        }
    }
}

extension SettingsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let gap: CGFloat = 10
        let cellWidth = collectionView.frame.width / 3 - gap - (gap / 3)
        let cellHeight = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SettingCell
        cell.titlelabel.text = "\(features[indexPath.row])"
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
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = features.remove(at: sourceIndexPath.item)
        features.insert(temp, at: destinationIndexPath.item)
        showButton(doneButton)
    }
    
}
