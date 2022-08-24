//
//  ShotViewHostingController.swift
//  Nitelive
//
//  Created by Sam Santos on 6/1/22.
//

import SwiftUI
import AVFoundation



class ShotViewHostingController: UIHostingController<ShotView>{
    
    var shot: Shot!
    var club: Club
    var player: AVPlayer
    
    @StateObject var userManager: UserManager
    @StateObject var clubData: FirebaseData

    
    init(shot: Shot, club: Club, userManager: UserManager, clubData: FirebaseData){
        self.shot = shot
        self.club = club
        self.player = AVPlayer(url: shot.videoUrl)
        
        self._userManager = StateObject(wrappedValue: userManager)
        self._clubData = StateObject(wrappedValue: clubData)
        super.init(rootView: ShotView(shot: shot, club: club, userManager: userManager, clubData: clubData, player: player))
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
