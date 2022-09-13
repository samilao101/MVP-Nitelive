//
//  ShotView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/1/22.
//

import SwiftUI
import AVFoundation

struct ShotView: View{
    var shot: Shot
    var club: Club
    var player: AVPlayer
    @State var playStatus : AVPlayer.Status = .unknown
    @State var isVideoPlaying: Bool = false {
        didSet {
            print("updated bool")
        }
    }

    @StateObject var userManager: UserManager
    @StateObject var clubData: FirebaseData

    
    init(shot: Shot, club: Club, userManager: UserManager, clubData: FirebaseData, player: AVPlayer) {
        self.shot = shot
        self.club = club
        self._userManager = StateObject(wrappedValue: userManager)
        self._clubData = StateObject(wrappedValue: clubData)
        self.player = player
        self.playStatus = player.status
        
      
    }
 
    var body: some View{
        
 
        ShotInfo(club: club, userManager: userManager, clubData: clubData, uploaderUID: shot.fromId, timeStamp: shot.timeStamp) {
            
            ZStack{
            ShotPlayer(player: player, isVideoPlaying: $isVideoPlaying)
                .ignoresSafeArea()
                if !isVideoPlaying {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
            
        }
        
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}
