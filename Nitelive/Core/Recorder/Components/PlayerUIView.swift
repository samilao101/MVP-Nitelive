//
//  PlayerUIView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import SwiftUI
import AVKit
import AVFoundation


class PlayerUIView: UIView {
    
    private let playerLayer = AVPlayerLayer()
    var player : AVPlayer
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    init(frame: CGRect, player: AVPlayer) {
        self.player = player
        super.init(frame: frame)
   
        
        // Setup the player
        let player = player
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // Setup looping
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        // Start the movie
        player.play()
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
