//
//  Entry.swift
//  Nitelive
//
//  Created by Sam Santos on 5/29/22.
//

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .font(.system(size: 34))
            .padding(10)
    }
}

import SwiftUI

struct SelfieView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selfieImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    @State var animate = false
    @State var opacity = 0.0
    
    @Binding var userName: String
    @Binding var capturedImaged: UIImage?
    
    var body: some View {
        ZStack {
            Color.black
            if capturedImaged != nil {
                
                ZStack {
                    
                    Image(uiImage: capturedImaged!)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    Color.black
                        .ignoresSafeArea()
                        .opacity(animate ? 0.6: 0.0)
                        .onAppear {
                            withAnimation(Animation.spring().speed(0.5)) {
                                animate = true
                            }
                        }
                    VStack{
                        Text("2. Type Username:")
                        TextField("Username", text: $userName)
                            .underlineTextField()
                            .padding()
                    }

                }
            } else
                {
                VStack{
                    Text("1. Take a Selfie.")
                        .font(.system(size: 18))
                    Image(systemName: "arrow.down")
                        .font(.system(size: 24))
                }
                .foregroundColor(.white)
                .font(.system(.largeTitle))
            }
            VStack {
                HStack {
                    Button {
                        capturedImaged = nil
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .padding()
                    Spacer()
                    if !userName.isEmpty {
                        Button {
                            if capturedImaged != nil {
                                selfieImage = capturedImaged
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("Done.")
                                .opacity(opacity)
                                .onAppear{
                                    withAnimation{
                                        opacity = 1.0
                                    }
                                }
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .animation(Animation.easeInOut(duration:0.75).repeatForever(autoreverses:true))
                        }
                        .padding()
                        .padding()
                    }
                }
                Spacer()
                Button {
                    animate = false
                    isCustomCameraViewPresented.toggle()
                } label: {
                    VStack{
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        if capturedImaged != nil {
                            Text("Retake photo")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom)
                .sheet(isPresented: $isCustomCameraViewPresented) {
                    CustomCameraView(capturedImaged: $capturedImaged)
                }
                
            }
        }
    }
}



//struct Entry_Previews: PreviewProvider {
//    static var previews: some View {
//        SelfieView()
//    }
//}
