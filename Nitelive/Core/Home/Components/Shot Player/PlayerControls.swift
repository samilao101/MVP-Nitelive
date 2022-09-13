//
//  PlayerControls.swift
//  Nitelive
//
//  Created by Sam Santos on 5/5/22.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation


class PlayerControls: UIView {
    
    private var playerStatusContext = 0
    var delegate: PlayUpdateDelegate?

    
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
        
        player.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: &playerStatusContext)

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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        //  Check status
        if keyPath == "status" && context == &playerStatusContext && change != nil
        {
            let status = change![.newKey] as! Int
            //  Status is not unknown
            print("buffering status")
            delegate?.videoIsBuffering()
            
            if(status != AVPlayer.Status.unknown.rawValue)
            {
                print("playing status")
                delegate?.videoIsPlaying()
            }
        }
    }
}
