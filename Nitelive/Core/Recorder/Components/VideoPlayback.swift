//
//  VideoPlayback.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import Foundation

import UIKit
import AVFoundation

class VideoPlayback: UIViewController {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    weak var videoView: UIView!

    var videoURL: URL!
    //connect this to your uiview in storyboard
    override func viewDidLoad() {
    super.viewDidLoad()

    avPlayerLayer = AVPlayerLayer(player: avPlayer)
    avPlayerLayer.frame = view.bounds
    avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoView.layer.insertSublayer(avPlayerLayer, at: 0)

    view.layoutIfNeeded()

    let playerItem = AVPlayerItem(url: videoURL as URL)
    avPlayer.replaceCurrentItem(with: playerItem)

    avPlayer.play()
}
}
