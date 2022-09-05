//
//  thumbnailLooper.swift
//  Nitelive
//
//  Created by Sam Santos on 6/9/22.
//

import SwiftUI

struct thumbnailLooper: View {
    
    var initialCount: Int { images.count }
    @State var count: Int = 0
    @State var images: [UIImage]
    
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    var presentedImage: UIImage { images[count] }
    
    var body: some View {
        ZStack{
            
                Image(uiImage: presentedImage)
                    .resizable()
                    .rotationEffect(.degrees(90))
                    .scaledToFill()
                    .frame(width:  55, height:  55)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .offset(y: -11)
                    .onReceive(timer) { _ in
                        if count < initialCount - 1 {
                            count += 1
                            print(presentedImage.size)
                        } else {
                            count = 0
                        }
                    }
            
        }
         

    }
}

//struct thumbnailLooper_Previews: PreviewProvider {
//    static var previews: some View {
//        thumbnailLooper()
//    }
//}

//    @State private var expand: Bool = false

//var body: some View {
//    ZStack{
//        if expand {
//            Image(uiImage: presentedImage)
//                .resizable()
//                .rotationEffect(.degrees(90))
//                .scaledToFill()
//                .frame(width:  255, height: 455)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .overlay(Circle().stroke(Color.white, lineWidth: 3))
//                .offset(y: -11)
//                .onReceive(timer) { _ in
//                    if count < initialCount - 1 {
//                        count += 1
//                        print(presentedImage.size)
//                    } else {
//                        count = 0
//                    }
//                }
//
//        } else {
//            Image(uiImage: presentedImage)
//                .resizable()
//                .rotationEffect(.degrees(90))
//                .scaledToFill()
//                .frame(width:  55, height:  55)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white, lineWidth: 3))
//                .offset(y: -11)
//                .onReceive(timer) { _ in
//                    if count < initialCount - 1 {
//                        count += 1
//                        print(presentedImage.size)
//                    } else {
//                        count = 0
//                    }
//                }
//        }
//    }
//        .onLongPressGesture(minimumDuration: 3, maximumDistance: 5) {
//
//        } onPressingChanged: { (isPressing) in
//            if isPressing {
//                withAnimation(.easeInOut(duration: 10)){
//                    expand = true
//                }
//            } else {
//                expand = false
//            }
//        }

