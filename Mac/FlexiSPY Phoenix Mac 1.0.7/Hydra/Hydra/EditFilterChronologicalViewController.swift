//
//  EditChronologicalItemsViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/30/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

protocol EditFilterViewControllerDelegate {
    func didFinishUpdateFilter(filteredChronologicalItems: [ChronologicalItem])
}

class EditFilterChronologicalViewController: ViewController {
    
    var chronologicalItems: [ChronologicalItem] = [ChronologicalItem]()
    var tableViewDatasource = [Dictionary<String, Bool>]()
    var distinctServiceNames:[String] = [String]()
    var delegate: EditFilterViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    func setupUI() {
        self.navigationController?.navigationItem.hidesBackButton = true
    }
    
    func isDuplicated(serviceName: String) -> Bool {
        for item in tableViewDatasource {
            if item.first?.key == serviceName {
                return true
            }
        }
        return false
    }
    
    func isHidden(serviceName: String) -> Bool {
        for item in tableViewDatasource {
            if item.first?.key == serviceName {
                return (item.first?.value)!
            }
        }
        return false
    }
    
    func setupData() {
        
        for item in chronologicalItems {
            if let serviceName = item.serviceName ,
                isDuplicated(serviceName: serviceName) == false
                {
                var dict = Dictionary<String, Bool>()
                    dict[serviceName] = !item.isHidden
                    tableViewDatasource.append(dict)
            }
        }
    }
    
    func updatedChronologicalItems() -> [ChronologicalItem] {
        var updatedChronologicalItems = [ChronologicalItem]()
        for item in chronologicalItems {
            item.isHidden = !isHidden(serviceName: item.serviceName ?? "")
            updatedChronologicalItems.append(item)
        }
        
        return updatedChronologicalItems
    }
    
    //MARK: - IBAction
    @IBAction func done(){
        let updatedChronologicalItems = self.updatedChronologicalItems()
        delegate?.didFinishUpdateFilter(filteredChronologicalItems: updatedChronologicalItems)
        let _ = self.navigationController?.popViewController(animated: true)
    }
}

extension EditFilterChronologicalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDatasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? EditFilterCell else {
            return UITableViewCell()
        }
        
        let serviceNameAsDict = tableViewDatasource[indexPath.row]
        cell.nameLabel.text = serviceNameAsDict.first?.key
        
        let isChecked = serviceNameAsDict.first?.value
        if isChecked == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var serviceNameAsDict = tableViewDatasource[indexPath.row]
        if let key = serviceNameAsDict.first?.key,
           let isChecked = serviceNameAsDict.first?.value {
            serviceNameAsDict[key] = !isChecked
            tableViewDatasource[indexPath.row] = serviceNameAsDict
            tableView.reloadData()
        }
        
    }
}
