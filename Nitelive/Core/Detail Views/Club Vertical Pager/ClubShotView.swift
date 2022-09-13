//
//  ClubShotView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/3/22.
//

import SwiftUI
import AVFoundation

struct ClubShotView: View{
    var shot: Shot
    @State var showProfile: Bool = false
    @State var isVideoPlaying: Bool = false
    var player: AVPlayer
    
    @State var isANotification: Bool = false
    
    init(shot: Shot, player: AVPlayer) {
        self.shot = shot
        self.player = player
        self.isANotification = isANotification
        
    }
    
    var body: some View{
        ZStack{
            ShotPlayer(player: player, isVideoPlaying: $isVideoPlaying)
            TimeStampView(date: shot.timeStamp)
            VStack{
                HStack{
                    Spacer()
                    VideoUploaderUserView(fromUID: shot.fromId)
                        .padding()
                        .padding(.top, 50)
                    
                }
                Spacer()
            }
            
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}


