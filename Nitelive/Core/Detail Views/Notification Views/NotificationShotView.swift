//
//  NotificationShotView.swift
//  Nitelive
//
//  Created by Sam Santos on 9/3/22.
//

import SwiftUI
import AVKit

class NotificationShotViewModel: ObservableObject {
    
    @Published var clubName = ""
    @Published var club: Club?
    
    
    
    func getClub(clubId: String) {
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(clubId).getDocument { snap, error in
            if let error = error {
                print("Error getting club from notification: \(error.localizedDescription)")
                return
            }
            print("getting notification club")
            
            if let snap = snap {
                if let data = snap.data() {
                    print("creating club model")
                    
                    let tempClub = Club(id: snap.documentID, data: data)
                    self.club = tempClub
                    self.clubName = tempClub.name
                } else {
                    print("unable to get data")
                    return
                }
            } else {
                print("unable to get snap")
                return
            }
            
            
            
            
        }
        
    }
    
}

struct NotificationShotView: View{
    var shot: Shot
    @State var showProfile: Bool = false
    var player: AVPlayer
    @StateObject var clubLoader = NotificationShotViewModel()
    @State var isVideoPlaying: Bool = false

    
    @State var clubName = ""
    
    
    init(shot: Shot, player: AVPlayer) {
        self.shot = shot
        self.player = player
        
    }
    
    var body: some View{
        ZStack{
            ShotPlayer(player: player, isVideoPlaying: $isVideoPlaying)
            TimeStampView(date: shot.timeStamp)
            VStack{
                HStack{
                    Spacer()
                    VStack{
                    
//                        if let club = clubLoader.club {
//                            NavigationLink {
//                                    ClubView(club: club)
//                            } label: {
//                                Text("See Club Info >")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 32))
//                            }
//
//                        }
                        
                        VideoUploaderUserView(fromUID: shot.fromId)
                            .padding()
                            .padding(.top, 50)
                    }.padding()
                    
                    
                }
                Spacer()
            }
            
        }
        .ignoresSafeArea()
        .navigationTitle(clubLoader.clubName)
        .onAppear {
            clubLoader.getClub(clubId: shot.clubId)
            
        }
    }
}
