import SwiftUI
import AVFoundation



class ClubShotViewHostingController: UIHostingController<ClubShotView>{
    
    var shot: Shot!
    var player: AVPlayer

    
    init(shot: Shot){
        self.shot = shot
        self.player = AVPlayer(url: shot.videoUrl)

        super.init(rootView: ClubShotView(shot: shot, player: player))
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
