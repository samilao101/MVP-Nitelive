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
        
    @State var loadedShotThumbnails: Bool = false

    @State private var shots: [Shot]
    
    init(clubs: [Club], shots: [Shot]) {
        _mapManager = StateObject(wrappedValue: ClubsMapManager(clubs: clubs))
        self.shots = shots
    }
    
    init(oneClub: Club, shots: [Shot]) {
        _mapManager = StateObject(wrappedValue: ClubsMapManager(clubs: [oneClub]))
        self.shots = shots
    }
    
    var body: some View {
        ZStack{
            Map(coordinateRegion: $mapManager.region, showsUserLocation: true, annotationItems: mapManager.clubs){
                location in
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    
                    NavigationLink {
                        
                        ClubView(shots: getClubVideos(location: location), club: location)
                        
                    } label: {
                        ClubMarker(club: location, thumbnailURLs: getClubVideosThumbnailsUrls(club: location), loadedShotThumbnails: $loadedShotThumbnails)
                    }

                    
                }
                
               
                
            }
            .ignoresSafeArea()
            .accentColor(Color(.systemPink))
            
            VStack {
                HStack{
                    Spacer()
                    if loadedShotThumbnails == false && shots.count > 0 {
                        HStack{
                            Text("Loading")
                                .bold()
                            ProgressView()
                        }
                        .padding()
                    }
                }
                Spacer()
                
                
            }

        }
           
    }
    
    private func getClubVideosThumbnailsUrls(club: Club) -> [URL]? {
        
        var thumbnailsURLs = [URL]()
        
        let filteredShots = shots.filter { shot in
            shot.clubId == club.id
        }
            filteredShots.forEach { shot in
                thumbnailsURLs.append(shot.videoUrl)
            }
        if thumbnailsURLs.isEmpty {
            return nil
        } else {
            return thumbnailsURLs
        }
    }
    
    private func getClubVideos(location: Club) -> [Shot] {
        return shots.filter { shot in
            shot.clubId == location.id
        }
        
    }
}

//struct ClubMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
