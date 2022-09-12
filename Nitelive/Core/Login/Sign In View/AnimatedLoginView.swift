//
//  SwiftUIView.swift
//  Nitelive
//
//  Created by Sam Santos on 9/11/22.
//

import SwiftUI

struct AnimatedLoginView: View {
    
    @Binding var sheetModal: SheetMode
    @State var animate = false
    var loginSuccessFul: () -> ()
    
    var body: some View {
        ZStack {
            if sheetModal == .quarter {
                Color.black
                    .ignoresSafeArea()
                    .opacity(animate ? 0.6: 0.0)
                    .onTapGesture {
                        sheetModal = .none

                    }.onAppear {
                        withAnimation(Animation.spring().speed(0.5)) {
                            animate = true
                        }
                    }.onDisappear {
                        animate = false
                    }
                    
             }
            
            AnimatedLoginWithApple(sheetModal: $sheetModal, loginSuccessFul: loginSuccessFul)
            
        }
    }
    

}


