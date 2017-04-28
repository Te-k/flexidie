//
//  MailDetailViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/21/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class MailDetailViewController: UITableViewController, UIWebViewDelegate {

    var mail:Mail?
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var ccLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var cellMailBody: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Methods
    func setupUI() {
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        toLabel.preferredMaxLayoutWidth = 180
        ccLabel.preferredMaxLayoutWidth = 180
        subjectLabel.preferredMaxLayoutWidth = 180
        
        toLabel.text = mail?.formattedRecipientsAsString(recipientType: "To") ?? " "
        ccLabel.text = mail?.formattedRecipientsAsString(recipientType: "Cc") ?? " "
        subjectLabel.text = mail?.subject

        webView.loadHTMLString(mail?.mailBody ?? "", baseURL: nil)
        self.navigationItem.title = mail?.subject
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row != 3 {
            return UITableViewAutomaticDimension
        } else {
            return webView.scrollView.contentSize.height
        }
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        tableView.reloadData()
    }
    
}
