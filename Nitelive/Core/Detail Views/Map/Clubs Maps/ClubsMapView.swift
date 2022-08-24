//
//  ClubsMapView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/5/22.
//

import SwiftUI
import MapKit

struct ClubsMapView: View {
    
    @StateObject var mapManager : ClubsMapManager
    
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var  listOfClubs : FirebaseData
    
    init(clubs: [Club]) {
        _mapManager = StateObject(wrappedValue: ClubsMapManager(clubs: clubs))
    }
    
    init(oneClub: Club) {
        _mapManager = StateObject(wrappedValue: ClubsMapManager(clubs: [oneClub]))
    }
    
    var body: some View {
        ZStack{
            Map(coordinateRegion: $mapManager.region, showsUserLocation: true, annotationItems: mapManager.clubs){
                location in
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    
                    NavigationLink {
                        
                        ClubView(club: location)
                            .environmentObject(userManager)
                            .environmentObject(listOfClubs)
                        
                    } label: {
                        ClubMarker(club: location, thumbnailURLs: listOfClubs.getClubVideosThumbnailsUrls(club: location))
                    }

                    
                }
            }
            .ignoresSafeArea()
            .accentColor(Color(.systemPink))

        }
           
    }
}

//struct ClubMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
