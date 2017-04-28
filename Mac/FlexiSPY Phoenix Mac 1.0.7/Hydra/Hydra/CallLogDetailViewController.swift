//
//  CallLogDetailViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class CallLogDetailViewController: UITableViewController {

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordDirection: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var callLog:CallLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Methods
    func updateUI() {
        self.navigationItem.title = callLog?.phoneNumber
        contactNameLabel.text = callLog?.contactName
        dateLabel.text = callLog?.userTime?.formattedDateTimeString(toFormat: .dateWithFullName)
        timeLabel.text = callLog?.userTime?.formattedDateTimeString(toFormat: .time)
        recordDirection.text = callLog?.recordDirection?.formattedCallDirection()
        durationLabel.text = callLog?.duration?.toFormattedDurationString()
        phoneNumberLabel.text = callLog?.phoneNumber
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
}
