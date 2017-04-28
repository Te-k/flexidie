//
//  BaseSWTableTableViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/21/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit

class BaseSWTableTableViewController: UITableViewController, SWRevealViewControllerDelegate {

    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSWView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func setupSWView() {
        if self.revealViewController() != nil ,
            menuButton != nil
        {
            menuButton.target = self.revealViewController()
            self.revealViewController().delegate = self
            menuButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func setTableViewInteractionEnable(isEnabled: Bool) {
        self.tableView.bounces = isEnabled
        self.tableView.allowsSelection = isEnabled
    }
    
    // MARK: - SWViewControllerDelegate
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        switch position {
        case .right:
            print("right")
        case .left:
            print("left")
            setTableViewInteractionEnable(isEnabled: true)
        case .leftSideMost:
            print("leftSideMost")
        case .leftSide:
            setTableViewInteractionEnable(isEnabled: false)
            print("leftSide")
        case .leftSideMostRemoved:
            print("leftSideMostRemoved")
        case .rightMost:
            print("rightMost")
        case .rightMostRemoved:
            print("rightMostRemoved")
        }
    }


}
