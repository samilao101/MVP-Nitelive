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
    var player: AVPlayer
    
    init(shot: Shot, player: AVPlayer) {
        self.shot = shot
        self.player = player
        
    }
    
    var body: some View{
        ZStack{
            ShotPlayer(player: player)
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
