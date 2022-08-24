//
//  UserAvatarView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/16/22.
//


import SwiftUI

class UserAvatarViewModel: ObservableObject {
    
    @Published var image : UIImage = UIImage(systemName: "person")!
    let user: User
    
    
    init(user: User) {
        self.user = user
        getProfileImage(user: user)
    }
    
    func getProfileImage(user: User) {
        DispatchQueue.main.async {
            self.downloadProfileImage(imageId: user.uid) { result in
                switch result {
                case .success(let image):
                    self.image = image
                case .failure(_):
                    self.getProfileImage(user: user)
                    break
                }
            }
        }
       
    }
    
    
    func downloadProfileImage(imageId: String, handler: @escaping(Result<UIImage, Error>)->Void) {

     
        let logoStorage = FirebaseManager.shared.storage.reference().child("\(FirebaseConstants.profileImages)/\(imageId)/\(imageId)")

    
        logoStorage.getData(maxSize: 1 * 1024 * 1024) { data, error in
        
          if let error = error {
            print(error.localizedDescription)
         
          } else {
        
            let image = UIImage(data: data!)
            guard let newimage = image else { return }
            handler(.success(newimage))
          }

        }

    }
    
}


struct UserAvatarView: View {
    
    var name: String
    var size: CGFloat
    var withName: Bool
    
    @StateObject var vm : UserAvatarViewModel
    
    init(user: User, size: CGFloat = 60, withName: Bool = true) {
     
        _vm = StateObject.init(wrappedValue: UserAvatarViewModel(user: user))
        self.name = user.username
        self.size = size
        self.withName = withName
    }
    
    
    var body: some View {
        VStack{
        Image(uiImage: vm.image)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(lineWidth: 3))
         
            if withName {
                Text(name)
                        .foregroundColor(.white)
            }
        
        
        }
        
    }
}
