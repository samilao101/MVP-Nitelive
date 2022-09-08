//
//  MainViewManager.swift
//  Nitelive
//
//  Created by Sam Santos on 9/6/22.
//

import SwiftUI
import MapKit

class MainViewManager: ObservableObject {
    
    var clubs : [Club]
    var userLocation: CLLocationCoordinate2D?
    @Published var nearClub: Bool = false
    @Published var clubThatIsNear: Club?
    @ObservedObject var userManager: UserManager
    
    
    
    init(clubs: [Club], userLocation: CLLocationCoordinate2D?, userManager: UserManager) {
        self.clubs = clubs
        self.userLocation = userLocation
        _userManager = ObservedObject(wrappedValue: userManager)
        
    }
    
    func checkIfNearAnyClub() {
        print("Checking..")
        if let userLocation = userLocation {
            clubs.forEach { club in
                let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let distance = userLoc.distance(from: club.location)
                if distance <  1609/10 //1609*102  
                {
                    clubThatIsNear = club
                    nearClub = true
                    userManager.checkInCurrentClub(club: club)
                    print("checked in")
                }
            }
        } else {
            clubThatIsNear = nil
            nearClub = false
            if userManager.currentClub != nil {
                userManager.checkOutCurrentClub()
            }
            
            print("not near any club")
        }
    }
    
}
