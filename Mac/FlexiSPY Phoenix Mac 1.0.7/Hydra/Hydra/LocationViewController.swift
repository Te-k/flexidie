//
//  LocationViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/26/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import UIKit
import MangroveServiceManager
import MapKit

class LocationViewController: ViewController {
    var location: Location?
    var isTrackingModeEnable = false
    var timer: Timer?
    var isModeButtonsHidden = false
    
    @IBOutlet weak var trackingButtonImage: UIImageView!
    @IBOutlet weak var locationButtonImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var modeButtonsContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    func requestData() {
        let msController = HydraController.sharedInstance.msController
        let request = MSGetLocationRequest()
        request.deviceId = HydraController.sharedInstance.logonUser.license?.device?.ID
        request.delegate = self
        msController.send(request: request)
    }
    
    func setupUI() {
        modeButtonsContainer.isHidden = isModeButtonsHidden
    }
    
    func setupData() {
        if location == nil {
            requestData()
        } else{
            updateMapView()
        }
    }
    
    func updateMapView() {
        if let latitude = self.location?.latitude ,
            let longitude = self.location?.longitude {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinate
            if location?.cellName?.characters.count == 0 {
                let location = CLLocation(latitude: latitude, longitude: longitude)
                requestAndUpdateAnnotationName(annotation: annotation, location: location)
            } else {
                annotation.title = location?.cellName
            }
            annotation.subtitle = "Accuracy: \(location?.horizontalAccuracy ?? 0)"
            mapView.addAnnotation(annotation)
            mapView.showAnnotations([annotation], animated: true)
        }
    }
    
    func requestAndUpdateAnnotationName(annotation: MKPointAnnotation, location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemark: [CLPlacemark]?, error: Error?) in
            if error == nil {
                annotation.title = placemark?.first?.name
            } else {
                self.showAlertMessage(message: error?.localizedDescription ?? "")
            }
        })
    }
    
    func startTrackingMode() {
        trackingButtonImage.alpha = 0.8
        isTrackingModeEnable = true
        requestData()
        let timeInterval = HydraController.sharedInstance.locationTimeInterval
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(LocationViewController.requestData), userInfo: nil, repeats: true)
    }
    
    func stopTrackingMode() {
        trackingButtonImage.alpha = 0.4
        isTrackingModeEnable = false
        if let _timer = timer {
            _timer.invalidate()
        }
    }

    @IBAction func requestMoreLastLocation(_ sender: Any) {
        stopTrackingMode()
        requestData()
    }
    
    @IBAction func changeTrackingMode(_ sender: Any) {
        if isTrackingModeEnable == false {
            startTrackingMode()
        } else {
            stopTrackingMode()
        }
    }
}

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "location")
        
        if pinView == nil {
            pinView  = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "location")
            pinView?.canShowCallout = true
            pinView?.annotation = annotation
        } else {
            pinView?.annotation = annotation
        }
            pinView?.isEnabled = true
            return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("User Tabbed")
    }
}

extension LocationViewController: MangroveServiceManagerDelegate {
    func requestCompleted(request: MSRequest, response: MSResponse?) {
        switch response {
        case let response as MSGetLocationResponse:
            if let  location = response.location {
                self.location = location
                updateMapView()
            } else {
                self.showAlertMessage(message: "No records found.")
            }
        default:
            print("Cannot Hanndle a response")
        }
    }
    
    override func requestError(error: Error?) {
        let alertView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}
