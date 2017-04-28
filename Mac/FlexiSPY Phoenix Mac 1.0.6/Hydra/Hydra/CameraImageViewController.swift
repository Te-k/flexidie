//
//  PhotosViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/20/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager

class CameraImageViewController: BaseSWViewController, MangroveServiceManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var images: [CameraImage] = [CameraImage]()
    var currentPageNumber = 0
    var totalPages = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -Methods
    
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetCameraImageRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.pageNumber = currentPageNumber + 1
        request.delegate = self
        msController.send(request: request)
    }
    
    // MARK: - CollectionView Datasource & Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ImagePopupViewController") as? ImagePopupViewController {
            viewController.images = images
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
    
    // MARK: - MangroveServiceManagerDelegate
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetCameraImageResponse:
            if let  newImages = response.images
                , newImages.count > 0 {
                images.append(contentsOf: newImages)
                currentPageNumber = response.pageNumber ?? 1
                collectionView.reloadData()
            }
            totalPages = response.totalPages ?? 0
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
