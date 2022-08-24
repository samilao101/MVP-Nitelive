//
//  MapViewModel.swift
//  Nitelive
//
//  Created by Sam Santos on 5/18/22.
//

import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    static let defaultSpanZoomOut = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)

}

final class MapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var club: Club
    @Published var region: MKCoordinateRegion
    
    init(club: Club) {
        self.club = club
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: club.lat, longitude: club.lon), span: MapDetails.defaultSpan)
    }
    
}
