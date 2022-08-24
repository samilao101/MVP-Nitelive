//
//  ProfileView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var userManager: UserManager
    @State var loginStatusMessage = ""
    @State var image: UIImage?
    @State private var shouldShowImagePicker = false

    
    var body: some View {
      
        ZStack {
            
            if userManager.isUserCurrentlyLoggedOut {
                
                LoginView( didCompleteLoginProcess: {
                        self.userManager.isUserCurrentlyLoggedOut = false
                        self.userManager.fetchCurrentUser()

                })
               


            } else {

                ProfileImageView(image: userManager.profileImage
                                 ?? UIImage(imageLiteralResourceName: "club"), userName: userManager.currentUser?.username ?? "None").environmentObject(userManager)
            }
            
        }
     
        .navigationTitle("")
        .ignoresSafeArea()
        
        
    }
    
    

 
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}


//                VStack {
//                    HStack {
//                        Button {
//                            vm.handleSignOut()
//                        } label: {
//                            Text("Log out")
//                        }
//
//                    }
//                        Text("Hello user \(String(vm.currentUser?.email ?? "")) ")
//                }
