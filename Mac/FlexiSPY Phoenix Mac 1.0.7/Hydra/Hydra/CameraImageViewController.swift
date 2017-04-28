//
//  PhotosViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class CameraImageViewController: BaseSWViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var images: [CameraImage] = [CameraImage]()
    var currentPageNumber = 0
    var totalPages = 0
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -Methods
    func setupUI() {
        refreshControl.addTarget(self, action: #selector(CameraImageViewController.handleRefresh), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CameraImageViewController.requestData), userInfo: nil, repeats: false)
    }
    
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetCameraImageRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = currentPageNumber + 1
        request.delegate = self
        msController.send(request: request)
    }
}

extension CameraImageViewController: MangroveServiceManagerDelegate {
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetCameraImageResponse:
            if let  newImages = response.images
                , newImages.count > 0 {
                self.images = newImages
                self.collectionView.reloadWithFadeAnimation(section: 0)

            } else {
                self.showAlertMessage(message: "No records found.")
            }
            totalPages = response.totalPages ?? 0
        default:
            print("Cannot Hanndle a response")
        }
        refreshControl.endRefreshing()
    }
    
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        refreshControl.endRefreshing()
    }
}

extension CameraImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ImagePopupViewController") as? ImagePopupViewController {
            viewController.imageUrls = Helper.cameraImageUrls(images: images)
            viewController.currentPage = indexPath.row
            let navVC = UINavigationController(rootViewController: viewController)
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as? ImageCell
            else {
                return UICollectionViewCell()
        }
        let cameraImage = images[indexPath.row]
        if let url = URL(string: cameraImage.imageThumbnailURL ?? "" ) {
            cell.imageView.setImage(url: url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let  gap :CGFloat = 3
        let width = collectionView.frame.width/4 - gap
        let height = width
        return CGSize(width: width, height: height)
    }
}
