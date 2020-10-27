//
//  MapController.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 16.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import UIKit
import MapKit

protocol MapControllerDelegate {
    func getAddress(_ address: String?)
}


class MapController: UIViewController {
    var mapControllerDelegate: MapControllerDelegate?
    let place = Place()
    let locationManager = LocationManager()
    var identifierSegue = ""
    var placeCoord: CLLocationCoordinate2D? = nil
    var availableDirections: [MKDirections] = []
    var previouseLocation: CLLocation? = nil
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mappin: UIImageView!
    @IBOutlet weak var done: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setAnnotationView()
        locationManager.initialization(mapView) {
            locationManager.locationManager?.delegate = self
        }
        if identifierSegue == "setPlace" {
            directionButton.isHidden = true
            label.text = ""
        } else {
            done.isHidden = true
            label.isHidden = true
            mappin.isHidden = true
        }
    }
    
    func setAnnotationView() {
        guard let address = place.address else {
            return }
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            guard let placeLocationCoord = placemarks.first?.location?.coordinate else { return }
            let annotationView = MKPointAnnotation()
            annotationView.coordinate = placeLocationCoord
            annotationView.title = self.place.name
            annotationView.subtitle = self.place.type
            self.mapView.addAnnotations([annotationView])
            self.mapView.selectAnnotation(annotationView, animated: true)
            self.locationManager.setRegion(self.mapView, placeLocationCoord)
            self.placeCoord = placeLocationCoord
        })
    }
    
    func getDirection() {
        let request = MKDirections.Request()
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        guard let sourceCoord = locationManager.locationManager?.location?.coordinate else { return }
        guard let distCoord = placeCoord else { return }
        locationManager.locationManager?.startUpdatingLocation()
        previouseLocation = CLLocation(latitude: sourceCoord.latitude, longitude: sourceCoord.longitude)
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoord))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: distCoord))
        let directions = MKDirections(request: request)
        clearDirections(directions)
        directions.calculate {
            (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let routes = response?.routes else { return }
            for route in routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.locationManager.setUserLocation(self.mapView)
            })
        }
    }
    
    func getCenterLocation() -> CLLocation {
        let center = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        return center
    }
    
    func clearDirections(_ directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directions.cancel()
    }
    
    @IBAction func onPressUserLocation() {
        locationManager.setUserLocation(mapView)
    }
    
    @IBAction func onDirection(_ sender: UIButton) {
       getDirection()
        
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        mapControllerDelegate?.getAddress(label.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClose() {
        dismiss(animated: true)
    }
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        if let data = place.imagePlace, let image = UIImage(data: data) {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = image
            annotationView!.rightCalloutAccessoryView = imageView
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
    
   func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    let center = getCenterLocation()
    let geocoder =  CLGeocoder()
        geocoder.reverseGeocodeLocation(center, completionHandler: { (placemarks, error) in
        if let error = error {
            print(error)
            return
        }
        guard let placemark
            = placemarks?.first else { return }
        guard let street = placemark.thoroughfare, let house = placemark.subThoroughfare else { return }
        DispatchQueue.main.async {
            self.label.text = "\(street), \(house)"
        }
    })

    
    if identifierSegue == "showPlace" && previouseLocation != nil {
        guard let location = locationManager.locationManager?.location?.coordinate else { return }
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        if center.distance(from: userLocation) < 50 { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.locationManager.setUserLocation(mapView)
        })
    }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard let previouseLocation = previouseLocation else {
            return
        }
        if previouseLocation.distance(from: location) < 50 { return }
        self.previouseLocation = location
        locationManager.setRegion(mapView, location.coordinate)
    }
}

extension MapController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.locationServicesAuthorizationHandler(mapView, status: status)
    }
}
