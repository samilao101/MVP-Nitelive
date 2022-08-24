//
//  ProfileImageView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/6/22.
//

import SwiftUI

struct ProfileImageView: View {
    
    let image: UIImage
    let userName: String
    @EnvironmentObject var userManager: UserManager
    @State var newImage: UIImage?
    @State private var shouldShowImagePicker = false
    @State var loginStatusMessage = ""
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(25)
                .padding()
            
          
            VStack {
                Spacer()
                HStack{
                    Text(userName)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                    Spacer()
                }
                
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    userManager.handleSignOut()
                } label: {
                    Text("Sign Out")
                }

            }
            
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        shouldShowImagePicker.toggle()
                    } label: {
                        Label("Retake", systemImage: "camera")
                            .foregroundColor(.white)
                    }

                }
            }
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: {
            if newImage != nil {
                guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                persistImageToStorage(uid: uid)
            }
            
        }) {
            SelfieView(capturedImaged: $newImage)
        }
    }
    
    private func persistImageToStorage(uid: String) {
       
        let ref = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.profileImages)/\(uid)/\(uid)")
        guard let imageData = self.newImage?.jpegData(compressionQuality: 0.1) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString ?? "")
                
                userManager.getProfileImage(imageId: uid )
                
            }
        }
    }
}

struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageView(image: UIImage(imageLiteralResourceName: "club"), userName: "Samilao101")
    }
}
