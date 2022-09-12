//
//  SelfieUserNameView.swift
//  Nitelive
//
//  Created by Sam Santos on 9/12/22.
//

import SwiftUI

struct SelfieUserNameView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selfieImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    @Binding var showCam: Bool
    
    @Binding var userName: String
    @Binding var capturedImaged: UIImage?
    
    var body: some View {
        ZStack {
            CustomCameraView(capturedImaged: $capturedImaged)
            
            if capturedImaged != nil {
                
                ZStack {
                    Image(uiImage: capturedImaged!)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    TextField("Username", text: $userName)
                        .underlineTextField()
                        .padding()
                    VStack {
                        Spacer()
                        Button {
                            showCam.toggle()
                            showCam.toggle()
                        } label: {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding(.bottom)
                    }
                }
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
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .padding()
                    }
                }
                Spacer()
                
            }
            
        }
        .onAppear {
            selfieImage = nil
        }
        .ignoresSafeArea()
    }
}





//
//struct SelfieUserNameView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelfieUserNameView()
//    }
//}
