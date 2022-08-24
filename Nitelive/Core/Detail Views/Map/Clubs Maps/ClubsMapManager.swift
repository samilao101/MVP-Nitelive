//
//  ClubsMapManager.swift
//  Nitelive
//
//  Created by Sam Santos on 6/5/22.
//

import MapKit


final class ClubsMapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var clubs: [Club]
    @Published var region: MKCoordinateRegion
    
    init(clubs: [Club]) {
        self.clubs = clubs
        self.region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpanZoomOut)
    }
    
}
