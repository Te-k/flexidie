//
//  SidebarViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/9/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class SidebarViewController: ViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var sections = [Dictionary<String,[String]>]()
    var isSectionExpanded = false
    var isSidebarTransitioning = false
    private let rowCellFeatures = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexSet = IndexSet(integer: rowCellFeatures)
        tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSidebarTransitioning = false
    }
    
    //MARK: IBActions
    @IBAction func showProfileView(_ sender: Any) {
    
    }
    
    // MARK: - Methods
    func setupUI() {
        self.tableView.layer.borderColor = self.tableView.separatorColor?.cgColor
        self.tableView.layer.borderWidth = 0.5
    }
    
    func setupData() {
        sections = [Dictionary<String,[String]>]()
        sections.append(["Dashboard": ["Dashboard"]])
        sections.append(["Licenses": ["Licenses"]])
        let deviceModel = HydraController.sharedInstance.logonUser.license?.device?.model ?? ""
        sections.append(["Device": ["Device (\(deviceModel))"]])
        let supportedFeatureNames = HydraController.sharedInstance.supportedFeatureNames()
        sections.append(["Data": supportedFeatureNames!])
        sections.append(["Settings": ["Settings"]])
        
    }
    
    func navigationController(_ viewControllerIdentifier:String!) -> UINavigationController? {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: viewControllerIdentifier) else {
            return nil
        }
        let navVC =  UINavigationController(rootViewController: viewController)
        navVC.isToolbarHidden = false
        return navVC
    }
    
    // MARK: - UITableView Data Source & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        let menusInSection = section[section.keys.first!]
        let numRows = (menusInSection?.count)!
        if numRows == 1 {
            return numRows
        } else if numRows > 1, isSectionExpanded {
            return numRows
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionDict = self.sections[indexPath.section]
        let itemsInSection = sectionDict[sectionDict.keys.first!]
        let itemName = itemsInSection?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! MenuCell
        cell.titleLabel.text = itemName
        
        if (itemsInSection?.count)! > 1 {
            cell.titleLabel.frame.origin.x = (82 + 22)
        } else {
            cell.titleLabel.frame.origin.x = 82
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSidebarTransitioning == true {
            return
        }
        
        var navVCToPush:UINavigationController?
        switch indexPath.section {
        case 0:
            navVCToPush = navigationController("DashboardViewController")
        case 1:
            navVCToPush = navigationController("LicensesViewController")
        case 2:
            navVCToPush = navigationController("DeviceDetailViewController")
        case rowCellFeatures:
            let supportedFeatureNames = HydraController.sharedInstance.supportedFeatureNames()
            let featureName = supportedFeatureNames?[indexPath.row]
            if featureName == "Call" {
                navVCToPush = navigationController("CallLogViewController")
            } else if featureName == "AddressBook" {
                navVCToPush = navigationController("AddressBookViewController")
            } else if featureName == "SMS" {
                navVCToPush = navigationController("GroupedSMSListViewController")
            } else if featureName == "CameraImage" {
                navVCToPush = navigationController("CameraImageViewController")
            } else if featureName == "Email" {
                navVCToPush = navigationController("MailListViewController")
            }
        case 4:
            navVCToPush = navigationController("SettingsViewController")
        default: break
            
        }
        
        if navVCToPush != nil {
            self.revealViewController().pushFrontViewController(navVCToPush, animated: true)
            isSidebarTransitioning = true
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDict = self.sections[section]
        return sectionDict.keys.first
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionDict = self.sections[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40 ))
        view.backgroundColor = .white
        let titleSectionLabel = UILabel(frame: CGRect(x: 82, y: 10, width: tableView.frame.width , height: 30))
            titleSectionLabel.text = sectionDict.keys.first!
        let imageView = UIImageView(frame: CGRect(x: 140, y: 18, width: 16, height: 16 ))
        imageView.image = UIImage(named: "down-button")
        view.addSubview(imageView)
            view.addSubview(titleSectionLabel)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sectionTabbed(gesture:)))
        view.addGestureRecognizer(gesture)
        
        let seperator = UIView(frame: CGRect(x: 0, y: view.frame.height - 1, width: view.frame.width, height: 0.5 ))
        seperator.backgroundColor = tableView.separatorColor
        view.addSubview(seperator)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.5 ))
        view.backgroundColor = tableView.separatorColor
        return view
    }
    
    func sectionTabbed(gesture:UITapGestureRecognizer?) {
        isSectionExpanded = !isSectionExpanded
        let indexSet = IndexSet(integer: rowCellFeatures)
        tableView.reloadSections(indexSet, with: UITableViewRowAnimation.fade)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = self.sections[section]
        let menusInSection = section[section.keys.first!]
        let numRows = (menusInSection?.count)!
        
        if numRows == 1 {
            return 0
        } else {
            return 40
        }
    }

}
