//
//  RecordingTimer.swift
//  Nitelive
//
//  Created by Sam Santos on 6/6/22.
//

import SwiftUI

struct RecordingTimer: View {
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @Binding var startStop: Bool
    @State var count: Int = 10
    @State var action: () -> ()
    
    
    var body: some View {
        Text("\(count)")
            .foregroundColor(.white)
            .bold()
            .onReceive(timer) { _ in
                if !startStop {
                    count = 10
                } else {
                    count -= 1
                    if count == 0 {
                        action()
                    }
                }
            }
    }
    
}

struct RecordingTimer_Previews: PreviewProvider {
    static var previews: some View {
        RecordingTimer(startStop: .constant(true), action: {print("DOne")})
    }
}
