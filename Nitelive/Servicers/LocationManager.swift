//
//  LocationManager.swift
//  Nitelive
//
//  Created by Sam Santos on 9/19/22.
//

import Foundation
import CoreLocation
import MapKit

class LocationManger: NSObject, CLLocationManagerDelegate {
    
    @Published var gotUserLocation: Bool = false
    @Published var location: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    
    var locationManager: CLLocationManager?

    
    override init() {
        super.init()
   
        
        fetchUserLocation()

    }
    
    
    func fetchUserLocation() {
        checkIfLocationServicesIsEnabled()
    }
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("show alert asking them to turn it on")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            print("location services not determined")
            locationManager.requestWhenInUseAuthorization()
                gotUserLocation = false
        case .restricted:
            print("your location is restricted")
                gotUserLocation = false
        case .denied:
            print("you have denied this app location permission. go into authorizations to use it.")
                gotUserLocation = false
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized to use location services")
            if locationManager.location != nil {
                location = locationManager.location!.coordinate
                region = MKCoordinateRegion(center: location!, span: MapDetails.defaultSpan)
               
                   gotUserLocation = true
               
            }
            
        @unknown default:
            break
        }

    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    
}
