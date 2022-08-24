//
//  RecorderButton.swift
//  Nitelive
//
//  Created by Sam Santos on 5/12/22.
//

import SwiftUI

struct RecorderButton: View {
    
    @State var club: Club
    
    @State var image: Image
    
    @State var action: () -> Void
    
    @State private var animationAmount = 1.0
    
    
    var body: some View {
        
        
                    Button {
                        action()
                    } label: {
                        VStack {
                            ZStack{
                                ClubImage(clubId: club.id, shape: .circle, imageUrl: club.clubImageUrl)
                                .overlay(
                                    Capsule()
                                        .stroke(.red)
                                        .scaleEffect(animationAmount)
                                        .opacity(2 - animationAmount)
                                        .animation(
                                            .easeInOut(duration: 1)
                                                .repeatForever(autoreverses: false),
                                            value: animationAmount
                                        )
                                    
                                )
                                
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 80))
                                    .opacity(0.4)
                                
                            }
                                .onAppear {
                                    animationAmount = 2
                                }
                            Text(club.name)
                                .foregroundColor(.white)
                                .font(.system(size: 8))
                        }
                    }
                   
          

         

    }
}

//struct RecorderButton_Previews: PreviewProvider {
//    static var previews: some View {
//        RecorderButton(clubName: "Cuba Libre") {
//            
//        }
//    }
//}
