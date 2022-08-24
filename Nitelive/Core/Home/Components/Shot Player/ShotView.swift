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
    
    @StateObject var userManager: UserManager
    @StateObject var clubData: FirebaseData

    
    init(shot: Shot, club: Club, userManager: UserManager, clubData: FirebaseData, player: AVPlayer) {
        self.shot = shot
        self.club = club
        self._userManager = StateObject(wrappedValue: userManager)
        self._clubData = StateObject(wrappedValue: clubData)
        self.player = player

    }
 
    var body: some View{
        
 
        ShotInfo(club: club, userManager: userManager, clubData: clubData, uploaderUID: shot.fromId, timeStamp: shot.timeStamp) {
            
            ShotPlayer(player: player)
            
            
            
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}
