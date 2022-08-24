//
//  CustomCameraView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/29/22.
//

import SwiftUI

struct CustomCameraView: View {
    
    let cameraService  = CameraService()
    @Binding var capturedImaged: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
     
        ZStack {
            
            CameraView(cameraService: cameraService) { result in
                switch result {
                    
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        capturedImaged = UIImage(data: data)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Error: No image data found")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            VStack {
                Spacer()
                Button {
                    cameraService.capturePhoto()
                } label: {
                    Image(systemName: "circle")
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                }
                .padding(.bottom)

            }
            
        }
        
    }
}
