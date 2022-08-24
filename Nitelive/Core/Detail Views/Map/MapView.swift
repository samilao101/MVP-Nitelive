//
//  MapView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/11/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject var mapManager : MapManager
    
    @EnvironmentObject var userManager: UserManager

    
    
    init(club: Club) {
        _mapManager = StateObject(wrappedValue: MapManager(club: club))
    }
    
    var body: some View {
        ZStack{
            Map(coordinateRegion: $mapManager.region, annotationItems: [mapManager.club]){
                location in
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    
                   
                       ClubMarker(club: location)
                    

                    
                }
                
            }
            .ignoresSafeArea()
            .accentColor(Color(.systemPink))
            VStack{
                Text(mapManager.club.address)
                Spacer()
            }
        }.navigationTitle(mapManager.club.name)
           
    }
}

//struct ClubMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}


