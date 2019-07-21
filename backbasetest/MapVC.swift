//
//  MapVC.swift
//  backbasetest
//
//  Created by Egor Bryzgalov on 2/28/19.
//  Copyright © 2019 Egor Bryzgalov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var travelTimeLbl: UILabel!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    let loc = CLLocationManager()
    let request = MKDirections.Request()
    let formatter = MeasurementFormatter()

    var city: City!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .long
        formatter.locale = Locale(identifier: NSLocale.current.identifier)

        loc.delegate = self
        loc.desiredAccuracy = kCLLocationAccuracyBest
        loc.requestWhenInUseAuthorization()
        loc.startUpdatingLocation()
        
        actIndicator.startAnimating()
        
        setPin()
    }
    
    func setPin() {
        let location = CLLocation(latitude: city.lat, longitude: city.lon)
        let radius: CLLocationDistance = 1000
        let point = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius )
        self.mapView.setRegion(point, animated: true)
        //ставим булавку в указанном месте
        let pin = CLLocationCoordinate2D(latitude: city.lat, longitude: city.lon)
        
        let setPin = MKPointAnnotation()
        setPin.title = city.name
        setPin.subtitle = city.country
        setPin.coordinate = pin
        self.mapView.addAnnotation(setPin)
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLoc = loc.location
//        print("curent location", currentLoc!.coordinate)
        calculateDistanceInMiles(lat: currentLoc!.coordinate.latitude, lon: currentLoc!.coordinate.longitude)
    }
    
    func calculateDistanceInMiles(lat: Double, lon: Double) {
        
        let sourceP         = CLLocationCoordinate2DMake(lat, lon)
        let destP           = CLLocationCoordinate2DMake(city.lat, city.lon)
        let source          = MKPlacemark(coordinate: sourceP)
        let destination     = MKPlacemark(coordinate: destP)
        request.source      = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        
        request.transportType = .automobile;
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            if let response = response, let route = response.routes.first {
                let meters = Measurement(value: route.distance, unit: UnitLength.meters)
                self.distanceLbl.text = self.formatter.string(from: meters)
                self.travelTimeLbl.text = "\(Int(route.expectedTravelTime/3600)) Hours " + "\(Int((route.expectedTravelTime.truncatingRemainder(dividingBy: 3600))/60)) min"
                self.actIndicator.stopAnimating()
                
                
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

