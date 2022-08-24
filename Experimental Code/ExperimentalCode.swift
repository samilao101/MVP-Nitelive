//
//  ExperimentalCode.swift
//  Nitelive
//
//  Created by Sam Santos on 6/18/22.
//

import SwiftUI
import AVKit

struct ExperimentalCode: View {
    var body: some View {
        VideoPlayer(player: AVPlayer(url:  URL(string: "https://firebasestorage.googleapis.com:443/v0/b/tonight-2081c.appspot.com/o/LocationVideos%2Fwcj7I4Bsq5lnNHb2euJe%2F694E645A-3B06-4E9A-9E5B-D1AEF58818A1?alt=media&token=c211ef90-72a1-4e8c-9f5b-52778feed51a")!)) {
            VStack {
                Text("Watermark")
                    .foregroundColor(.black)
                    .background(.white.opacity(0.7))
                Spacer()
            }
            .frame(width: 400, height: 300)
        }
    }
}

struct ExperimentalCode_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentalCode()
            .ignoresSafeArea()
    }
}
