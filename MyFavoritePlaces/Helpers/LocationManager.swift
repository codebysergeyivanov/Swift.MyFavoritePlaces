//
//  LocationManager.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 16.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationManager {
    let mapRect = 10_000
    var locationManager: CLLocationManager?
    var placeCoord: CLLocationCoordinate2D?
    
    func initialization(_ mapView: MKMapView, clouser: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest;
            locationServicesAuthorizationHandler(mapView, status: CLLocationManager.authorizationStatus())
            clouser()
        } else {
            print("Location Servises Disabled")
        }
    }
    
    func locationServicesAuthorizationHandler(_ mapView: MKMapView, status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            print("Enable location to seettings")
            break
        case .notDetermined:
        locationManager?.requestWhenInUseAuthorization()
        break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        default:
            break
        }
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        let rvc = UIApplication.shared.windows.first!.rootViewController
        rvc?.present(alert, animated: true, completion: nil)
    }
    
    
    func setUserLocation(_ mapView: MKMapView) {
        guard let userLocationCoord = locationManager?.location?.coordinate else { return }
        setRegion(mapView, userLocationCoord)
    }
    
    func setRegion(_ mapView: MKMapView, _ currentRegion: CLLocationCoordinate2D) {
        let coordRegion = MKCoordinateRegion(center: currentRegion, latitudinalMeters: CLLocationDistance(mapRect), longitudinalMeters: CLLocationDistance(mapRect))
        mapView.setRegion(coordRegion, animated: true)
    }
}


