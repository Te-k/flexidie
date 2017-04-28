//
//  AddressBookViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class AddressBookViewController: BaseSWViewController, MangroveServiceManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    var dataArray:[Contact] = [Contact]()
    @IBOutlet weak var tableView: UITableView!
    
    let sections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#",]
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
    }
    
    // MARK: - UITableView Data Source & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let itemCount = dataArray.count
        if itemCount == 0 {
            return 0
        }
        
        return Int(arc4random_uniform(UInt32(itemCount)))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? AddressBookCell else {
            return UITableViewCell()
        }
        
        let data = dataArray[indexPath.row]
        cell.contactNameLabel.text = "\(data.firstname ?? "")  \(data.lastname ?? "")"
        
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
        let contact = dataArray[indexPath.row]
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController {
            viewController.contact = contact
            let _ = self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - MangroveServiceManagerDelegate
    
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetAddressBookResponse:
            dataArray = response.contacts ?? [Contact]()
            tableView.reloadData()
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections
    }
    
    func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
