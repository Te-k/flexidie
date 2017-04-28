//
//  ContactDetailViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/16/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager
import Alamofire
import WebImage

class ContactDetailViewController: UITableViewController {

    var contact:Contact?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var mobilePhoneNumberlabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var homePhoneNumberLabel: UILabel!
    @IBOutlet weak var workPhoneNumberLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -Methods
    func updateUI() {
        tableView.allowsSelection = false
        contactNameLabel.text = (contact?.firstname ?? "") + " " + (contact?.lastname ?? "")
        mobilePhoneNumberlabel.text = contact?.mobilePhoneNumber
        emailLabel.text = contact?.email
        homePhoneNumberLabel.text = contact?.homePhoneNumber
        workPhoneNumberLabel.text = contact?.workPhoneNumber
        notesLabel.text = contact?.notes
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if let url = URL(string:contact?.contactPicURL ?? "") {
            profileImageView.setImage(url: url)
        }
    }
}
