//
//  LocationTimeIntervalViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/9/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import UIKit

class LocationTimeIntervalViewController: UIViewController {

    var timeIntervals = [5,10,30,60]
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    func setupUI() {
        //let timeInterval = HydraController.sharedInstance.locationTimeInterval
    }
}

extension LocationTimeIntervalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeIntervals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        let timeInterval = timeIntervals[indexPath.row]
        if timeInterval == 60 {
            cell.textLabel?.text = "1 minute"
        } else {
            cell.textLabel?.text = "\(timeInterval) seconds"
        }
        
        
        if timeInterval == HydraController.sharedInstance.locationTimeInterval {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timeInterval = timeIntervals[indexPath.row]
        HydraController.sharedInstance.locationTimeInterval = timeInterval
        self.tableView.reloadData()
    }

}
