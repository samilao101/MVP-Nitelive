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
    @State var newUserName: String = ""
    @State private var shouldShowImagePicker = false
    @State var loginStatusMessage = ""
    @Environment(\.presentationMode) var presentation

    
    init(image: UIImage, userName: String) {
        self.image = image
        self.userName = userName
        print("Initializig profile image view")
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(25)
                .padding()
            
          
            VStack {
                HStack{
                    Button(role: .destructive) {
                        shouldShowImagePicker.toggle()
                    } label: {
                        Label("Retake", systemImage: "camera")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        userManager.handleSignOut()
                    } label: {
                        Text("Sign Out")
                            .foregroundColor(.white)
                    }

                }.padding(.horizontal)
                Spacer()
                HStack{
                    Text(userName)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                    Spacer()
                    Button {
                        FirebaseManager.shared.auth.currentUser?.delete()
                        userManager.isUserCurrentlyLoggedOut = true
                        presentation.wrappedValue.dismiss()
                        
                    } label: {
                        Text("Delete")
                            .frame(width: 75, height: 40)
                            .background(Color.red)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    
                }
                
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: {
            if newImage != nil {
                guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                persistImageToStorage(uid: uid)
            }
            
        }) {
            RedoImageView(capturedImaged: $newImage)
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
