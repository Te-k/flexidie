//
//  AddressBookViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class AddressBookViewController: ViewController {

    var allContacts: [Contact] = [Contact]()
    var dataSource: [String: [Contact?]] = [String: [Contact]]()
    @IBOutlet weak var tableView: UITableView!
    let sections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#",]
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetAddressBookRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = 1
        request.delegate = self
        msController.send(request: request)
    }
    
    func setupUI() {
        self.navigationItem.title = "Address Book"
        refreshControl.addTarget(self, action: #selector(AddressBookViewController.handleRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AddressBookViewController.requestData), userInfo: nil, repeats: false)
    }
    
    func setupData() {
        dataSource = [String: [Contact]]()
        for contact in  allContacts {
            var firstCharactorInCapital = ""
            if  let firstname = contact.firstname ,
                let character = firstname.firstCharacterInCapital(),
                sections.contains(character) == true
                {
                firstCharactorInCapital = character
            } else {
                firstCharactorInCapital = "#"
            }
            
            if let contactsInDataSource = dataSource[firstCharactorInCapital] {
                var tempContacts = contactsInDataSource
                tempContacts.append(contact)
                dataSource[firstCharactorInCapital] = tempContacts
            } else {
                dataSource[firstCharactorInCapital] = [contact]
            }
        }
    }
}

extension AddressBookViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let character = self.sections[section]
        if let contactsInSection = dataSource[character] {
            return contactsInSection.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? AddressBookCell else {
            return UITableViewCell()
        }
        
        let character = self.sections[indexPath.section]
        guard let contactsInSection = dataSource[character],
            let contact = contactsInSection[indexPath.row] else {
                return UITableViewCell()
        }

        cell.contactNameLabel.text = "\(contact.firstname ?? "")  \(contact.lastname ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionName = self.sections[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30 ))
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        let titleSectionLabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width , height: 30))
        titleSectionLabel.text = sectionName
        view.addSubview(titleSectionLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = self.sections[indexPath.section]
        guard let contactsInSection = dataSource[character],
            let contact = contactsInSection[indexPath.row] else {
                return
        }
        
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController {
            viewController.contact = contact
            let _ = self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension AddressBookViewController: MangroveServiceManagerDelegate {
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        refreshControl.endRefreshing()
    }
    
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetAddressBookResponse:
            allContacts = response.contacts ?? [Contact]()
            if allContacts.count == 0 {
                self.showAlertMessage(message: "No records found.")
            }
            self.setupData()
            tableView.reloadData()
        default:
            print("Cannot Hanndle a response")
        }
        refreshControl.endRefreshing()
    }
}
