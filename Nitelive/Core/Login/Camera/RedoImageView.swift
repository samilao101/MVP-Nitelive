//
//  RedoImageView.swift
//  Nitelive
//
//  Created by Sam Santos on 9/12/22.
//

import SwiftUI

struct RedoImageView: View {
    @State private var selfieImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    
    
    @Environment(\.presentationMode) private var presentationMode
    
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

                }
                
            } else {
                
                VStack{
                Text("Take a Selfie:")
                Text("Note: Only selfies of how you look tonight allowed.")
                        .font(.system(size: 18))
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
                Spacer()
                Button {
                    isCustomCameraViewPresented.toggle()
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding(.bottom)
                .sheet(isPresented: $isCustomCameraViewPresented) {
                    CustomCameraView(capturedImaged: $capturedImaged)
                }

            }
        }
    }
}
