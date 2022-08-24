//
//  ShotPlayer.swift
//  Nitelive
//
//  Created by Sam Santos on 5/5/22.
//

import Foundation
import SwiftUI
import AVKit

struct ShotPlayer: UIViewRepresentable {
    
    var player: AVPlayer
  

    func makeUIView(context: Context) -> UIView {

        let view = PlayerControls(frame: .zero, player: player)
            view.player = player
            
            return view
       
        
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {

    }

    
}
