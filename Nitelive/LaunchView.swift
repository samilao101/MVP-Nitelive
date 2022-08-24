//
//  LaunchView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/8/22.
//

import SwiftUI

struct LaunchView: View {
    
    @State private var loadingText: [String] = "Loading Clubs...".map { String($0) }
    @State private var showLoadingText: Bool = false
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State private var counter: Int = 0
    @State private var loops: Int = 0
    
    var body: some View {
        ZStack {
            Color.black
            
            Image("club")
                .resizable()
                .scaledToFill()
                .blur(radius: 8)

            
            ZStack {
                if showLoadingText {
                    HStack(spacing: 0) {
                        ForEach(0..<loadingText.count, id:\.self) { index in
                            Text(loadingText[index])
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.white)
                                .offset(y: counter == index ? -20 : 0)
                        }
                    }
                    .transition(AnyTransition.scale.animation(.easeIn))
                }
                
            }
            .offset(y: 70)
        }
        .onAppear {
            showLoadingText.toggle()
        }
        .onReceive(timer, perform: { _ in
            withAnimation(.spring()) {
                
                let lastIndex = loadingText.count - 1
                if counter == lastIndex {
                    counter = 0
                    loops += 1
                   
                } else {
                    counter += 1
                }
            }
        })
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
            .ignoresSafeArea()
    }
}
