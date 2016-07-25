//
//  PassportViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 20/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import MapKit

class PassportViewController: UIViewController , CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var passportView: UIView!
    var locationManager : CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()

        passportView.layer.cornerRadius = 5
        passportView.layer.shadowRadius = 4
        passportView.layer.shadowOpacity = 0.05
        passportView.layer.shadowColor = UIColor.blackColor().CGColor
        passportView.layer.shadowOffset = CGSizeZero
        passportView.layer.borderColor = currentTheme.shadeColor.CGColor
        passportView.layer.borderWidth = 1
        
        map.layer.shadowRadius = 8
        map.layer.shadowOpacity = 0.1
        map.layer.shadowColor = UIColor.blackColor().CGColor
        map.layer.shadowOffset = CGSizeZero
        map.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        map.layer.borderWidth = 1
        
        map.showsUserLocation = true
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager!.requestWhenInUseAuthorization()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.startUpdatingLocation()

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
    }
    

}
