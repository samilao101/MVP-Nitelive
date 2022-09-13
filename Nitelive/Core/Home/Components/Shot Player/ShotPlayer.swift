//
//  ShotPlayer.swift
//  Nitelive
//
//  Created by Sam Santos on 5/5/22.
//

import Foundation
import SwiftUI
import AVKit

protocol PlayUpdateDelegate {
    func videoIsBuffering()
    func videoIsPlaying()
}

struct ShotPlayer: UIViewRepresentable {

    
    var player: AVPlayer
    @Binding var isVideoPlaying: Bool
    

  

    func makeUIView(context: Context) -> UIView {

        let view = PlayerControls(frame: .zero, player: player)
        view.delegate = context.coordinator
        view.player = player
            
        return view
       
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {

    }

    
    class Coordinator: PlayUpdateDelegate {
        
        var parent: ShotPlayer
        
        init(_ parent: ShotPlayer) {
            self.parent = parent
        }
        
        func videoIsPlaying() {
            parent.isVideoPlaying = true
        }
        
        func videoIsBuffering() {
            parent.isVideoPlaying = false
        }
    }
    
}
