//
//  LoginCameraView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/30/22.
//

import SwiftUI

struct LoginCameraView: View {
    
    let cameraService = CameraService()
    
    @Binding var capturedImaged: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var userManager: UserManager
    
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
            
            if capturedImaged != nil {
                
                Image(uiImage: capturedImaged!)
                
            } 
            
            
            VStack {
                HStack {
                    
                    Button {
                        
                        presentationMode.wrappedValue.dismiss()
                       
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    Button {
                       
                        capturedImaged = nil
                        
                    } label: {
                        Text("Retry")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    if capturedImaged != nil {
                        Button {
                          
                            if capturedImaged != nil {
                                persistImageToStorage()
                            }
                            
                        } label: {
                            Text("Done.")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
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
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.profileImages)/\(uid)/\(uid)")
        guard let imageData = self.capturedImaged?.jpegData(compressionQuality: 0.1) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print(err)
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    print(err)
                    return
                }
                
                print(url?.absoluteString ?? "")
                userManager.getProfileImage(imageId: uid)
            }
            
            
        }
    }
}
