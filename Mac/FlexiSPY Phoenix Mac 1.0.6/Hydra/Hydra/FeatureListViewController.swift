//
//  FeatureListViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/22/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

protocol FeatureListViewControllerDelegate {
    func featureListDidSelectItem(featureName: String)
}

class FeatureListViewController: UIViewController {

    fileprivate var featuresNotPersisted: [String]!
    
    @IBOutlet weak var tableView: UITableView!
    var delegate:FeatureListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        tableView.reloadData()
    }
    
    func setupData() {
        if let persistedFeatures = HydraController.sharedInstance.persistedFeaturesWithLogonUser() {
            let allFeatures = HydraController.sharedInstance.supportedFeatureNames()
            featuresNotPersisted = allFeatures?.filter({ !persistedFeatures.contains($0) })
        } else {
            featuresNotPersisted = HydraController.sharedInstance.supportedFeatureNames()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FeatureListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuresNotPersisted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FeatureCell
        cell.titlelabel.text = featuresNotPersisted[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let featureName = featuresNotPersisted[indexPath.row]
        self.dismiss(animated: true) {
            self.delegate?.featureListDidSelectItem(featureName: featureName)
        }
    }

}
