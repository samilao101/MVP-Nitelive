//
//  Player.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import Foundation
import SwiftUI
import AVKit

struct Player: UIViewRepresentable {
    
    var player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView(frame: .zero, player: player)
        view.player = player
        
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        
    }

    
}
