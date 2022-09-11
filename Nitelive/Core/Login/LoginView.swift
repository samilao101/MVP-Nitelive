//
//  LoginView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift


struct LoginView: View {
    
    @State var preferredColorScheme: ColorScheme? = nil
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var userName = ""
    @State private var password = ""
    @State var loginStatusMessage = ""
    @State var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
              
                HStack{
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("< back")
                            .bold()
                            .padding(.leading)
                            
                    }
                    Spacer()
                }

                VStack(spacing: 16) {
                    
                    Text(isLoginMode ? "Log In" : "Create Account")
                        .font(.system(size: 30))
                        .bold()

                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color.black, lineWidth: 3)
                            )
                            
                        }
                    }
                    
                    Group {
//                        TextField("Email", text: $email)
//                            .keyboardType(.emailAddress)
//                            .autocapitalization(.none)
                        if !isLoginMode {
                            TextField("Username", text: $userName)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                        }
                        
//                        SecureField("Password", text: $password)
                    }

                    .padding(12)
                    
//                    Button {
//                        handleAction()
//                    } label: {
//                        HStack {
//                            Spacer()
//                            Text(isLoginMode ? "Log In" : "Create Account")
//                                .foregroundColor(.white)
//                                .padding(.vertical, 10)
//                                .font(.system(size: 14, weight: .semibold))
//                            Spacer()
//                        }.background(Color.blue)
//
//                    }
                    
//                    GoogleSignInButton(action: handleSignInButton)
                    
                    ActivityIndicatorView(isPresented: $activityIndicatorInfo.isPresented, message: activityIndicatorInfo.message) {
                        SignInWithAppleView(activityIndicatorInfo: $activityIndicatorInfo, alertInfo: $alertInfo, completedLogin: startLogin)
                            .frame(width: 300, height: 50)
                            
                    }
                 
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .preferredColorScheme(.light)
                .navigationBarHidden(true)
               
                .padding()
                
            }
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
        .preferredColorScheme(.light)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationTitle("")
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            SelfieView(capturedImaged: $image)
                .ignoresSafeArea()
        }
        
        
        
        
    }
    
    private func startLogin(data: [String: Any])  {
        handleAction(data: data)
    }
    
//    func handleSignInButton() {
//
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
//        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
//
//        GIDSignIn.sharedInstance.signIn(
//          with: FirebaseManager.shared.signInConfig,
//          presenting: rootViewController) { user, error in
//            guard let signInUser = user else {
//
//
//                return
//            }
//
//              authenticateUser(for: signInUser, with: error)
//
//            // If sign in succeeded, display the app's main content View.
//          }
//
//
//    }
//
//    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
//      // 1
//      if let error = error {
//        print(error.localizedDescription)
//        return
//      }
//
//      // 2
//      guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
//
//      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
//
//      // 3
//      Auth.auth().signIn(with: credential) { (_, error) in
//        if let error = error {
//          print(error.localizedDescription)
//        } else {
//            self.didCompleteLoginProcess()
//        }
//      }
//    }

    private func handleAction(data: [String: Any]) {
        if isLoginMode {
//            print("Should log into Firebase with existing credentials")
//            loginUser()
        } else {
            persistImageToStorage(data: data)
            //            print("Register a new account inside of Firebase Auth and then store image in Storage somehow....")
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
        }
    }
    
//
//    private func createNewAccount(data: [String: Any]) {
//        if self.image == nil {
//            self.loginStatusMessage = "You must select an avatar image"
//            return
//        }
//
//        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
//            if let err = err {
//                print("Failed to create user:", err)
//                self.loginStatusMessage = "Failed to create user: \(err)"
//                return
//            }
//
//            print("Successfully created user: \(result?.user.uid ?? "")")
//
//            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
//
//            self.persistImageToStorage()
//        }
//    }
    
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
                
                guard let url = url else { return }
                var userData = data
                userData[FirebaseConstants.profileImageUrl] =  url.absoluteString
                userData[FirebaseConstants.username] = userName
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
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                print("Success")
                
                self.didCompleteLoginProcess()
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
