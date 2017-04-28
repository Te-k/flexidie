//
//  ImagePopupViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class ImagePopupViewController: ViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var imageUrls :[String]! = [String]()
    var currentPage = 0
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeDoneButtonIfViewNotModal()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func updateUI() {
        var index = 0
        for imageUrl in imageUrls {
            var frame = scrollView.bounds
            frame.origin.x = frame.width * CGFloat(index)
            let imageView = ImageViewWithIndex(frame: frame)
            imageView.index = index
            imageView.contentMode = .scaleAspectFit
            if let url = URL(string: imageUrl) {
                imageView.setImage(url: url)
            }
            scrollView.addSubview(imageView)
            index += 1
        }
        let width = scrollView.frame.size.width * CGFloat(imageUrls.count)
        let height = scrollView.frame.size.height
        scrollView.contentSize = CGSize(width: width, height: height)
        scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * CGFloat(currentPage), y: 0)
        shareButton.action = #selector(share(_:))
        doneButton.action = #selector(closeView(_:))
    }
    
    func removeDoneButtonIfViewNotModal() {
        if self.presentingViewController == nil {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func currentImageInScrollView() -> UIImage? {
        let views = scrollView.subviews
        
        for view in views {
            if let imageViewWithIndex = view as? ImageViewWithIndex,
                    imageViewWithIndex.index == currentPage
                {
                    return imageViewWithIndex.image
            }
        }
        
        return nil
    }
    
    // ScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentPage = page
    }
    
    //MARK: - IBAcions
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: Any) {
        let image = currentImageInScrollView()
        let vc = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
        if #available(iOS 9.0, *) {
            vc.excludedActivityTypes = [UIActivityType.assignToContact,
                                        UIActivityType.print,
                                        UIActivityType.addToReadingList,
                                        UIActivityType.openInIBooks,
                                        UIActivityType.mail,
                                        UIActivityType.message,
                                        UIActivityType.copyToPasteboard,
                                        UIActivityType.postToFacebook,
                                        UIActivityType(rawValue: "com.apple.mobileslideshow.StreamShareService"),
                                        UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
                                        UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),]
        } else {
            vc.excludedActivityTypes = [UIActivityType.assignToContact,
                                        UIActivityType.print,
                                        UIActivityType.addToReadingList,
                                        UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
                                        UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),]
        }
        present(vc, animated: true, completion: nil)
    }
}
