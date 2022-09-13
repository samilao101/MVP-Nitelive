//
//  AnimatedLoginWithApple.swift
//  Nitelive
//
//  Created by Sam Santos on 9/11/22.
//

import SwiftUI

struct AnimatedLoginWithApple: View {
    
    @Binding var sheetModal: SheetMode
    @State var image: UIImage?
    @State private var shouldShowImagePicker = false
    @State var userName: String = "" {
        didSet {
            print("New Username:\(userName)")
        }
    }
    @State var data = [String:Any]()
    
    var loginSuccessFul: () -> ()
    

    
    var body: some View {
        FlexibleSheet(sheetMode: $sheetModal    ) {
            
            ZStack {
                Color.white
                ActivityIndicatorView(isPresented: $activityIndicatorInfo.isPresented, message: activityIndicatorInfo.message) {
                    SignInWithAppleView(activityIndicatorInfo: $activityIndicatorInfo, alertInfo: $alertInfo, completedLogin: checkIfUserExists)
                        .frame(width: UIScreen.main.bounds.width-30, height: 50)
                        .padding(.bottom, 50)
                        .padding(.trailing)
                        .padding(.leading)
        
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
        
         persistImageToStorage(data: self.data)
            
        } content: {
            SelfieView(userName: $userName, capturedImaged: $image)
                .ignoresSafeArea()
        }

 
    }
    
    
    private func checkIfUserExists(data: [String: Any])  {
        
        self.data = data
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(data[FirebaseConstants.uid] as! String).getDocument { snap, error in
            if let snap = snap {
                if snap.exists {
                    UserManager.instance.fetchCurrentUser()
                    UserManager.instance.isUserCurrentlyLoggedOut = false
                    loginSuccessFul()
                    
                } else {
                    
                    shouldShowImagePicker.toggle()
                    
                }
            }
        }
    
    }
    
    
    
    private func saveUserData() {
        
        
        
    }
    
    private func persistImageToStorage(data: [String: Any]) {
                
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.profileImages)/\(uid)/\(uid)")
        let thumbNailRef = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.profileImages)/\(uid)/\(uid).thumbnail")
        guard let imageData = self.image?.jpegData(compressionQuality: 0.1) else { return }
        
        self.image?.prepareThumbnail(of: CGSize(width: 455, height: 230), completionHandler: { thumbnailImage in
            if let thumbnailImage = thumbnailImage {
                guard let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.1) else {return}
                thumbNailRef.putData(thumbnailData)
            }
        })
        
        
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    print(err)
                    return
                }
                
                print(url?.absoluteString ?? "")
                
                guard let url = url else { return }
                var userData = data
                userData[FirebaseConstants.profileImageUrl] =  url.absoluteString
                userData[FirebaseConstants.username] = self.userName
                self.storeUserInformation(data: userData)
            }
        }
        
    }
    
    private func storeUserInformation(data: [String: Any]) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid).setData(data) { err in
                if let err = err {
                    print(err)
                    return
                }
                
                print("Success")
                self.sheetModal = .none
                UserManager.instance.fetchCurrentUser()
                UserManager.instance.isUserCurrentlyLoggedOut = false
                self.loginSuccessFul()
            }
    }
    
    
    // MARK: - Activity Indicator
    @State private var activityIndicatorInfo = SparkUIDefault.activityIndicatorInfo

    func startActivityIndicator(message: String) {
        activityIndicatorInfo.message = message
        activityIndicatorInfo.isPresented = true
    }

    func stopActivityIndicator() {
        activityIndicatorInfo.isPresented = false
    }

    func updateActivityIndicator(message: String) {
        stopActivityIndicator()
        startActivityIndicator(message: message)
    }
    
    // MARK: - Alert
    @State private var alertInfo = SparkUIDefault.alertInfo
    
    func presentAlert(title: String, message: String, actionText: String = "Ok", actionTag: Int = 0) {
        alertInfo.title = title
        alertInfo.message = message
        alertInfo.actionText = actionText
        alertInfo.actionTag = actionTag
        alertInfo.isPresented = true
    }
    
    func executeAlertAction() {
        switch alertInfo.actionTag {
        case 0:
            print("No action alert action")
            
        default:
            print("Default alert action")
        }
    }
    
}


