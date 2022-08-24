//
//  VideoUploaderUserView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/16/22.
//

import SwiftUI

class VideoUploaderUserViewModel: ObservableObject {
    
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    @Published var image : UIImage = UIImage(systemName: "person")!
    @Published var state: State = .idle
    @Published var user : User = MockData.users.user1

    
    let fromUID: String
    
    init(fromUID: String) {
        self.fromUID = fromUID
        getUser()
    }
    
    func getUser(){
        state = .loading
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(fromUID).getDocument { snapshot, error in
            
            if let error = error {
                print(" ⛔️ Error loading data from Firebase: \(error.localizedDescription)")
                self.state = .failed(error)
                return
            }
            
            if let data = snapshot?.data() {
                self.user = User(data: data)
                self.getProfileImage(user: self.user)
                
            }
        }
    }
    
    func getProfileImage(user: User) {
        DispatchQueue.main.async {
            self.downloadProfileImage(imageId: user.uid) { result in
                switch result {
                case .success(let image):
                    self.image = image
                    self.state = .loaded
                    print("loaded uploader profile")

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

struct VideoUploaderUserView: View {
    
    @StateObject var vm: VideoUploaderUserViewModel
    let size: CGFloat = 60
    @State var showProfile: Bool = false
    
    init(fromUID: String) {
        _vm = StateObject.init(wrappedValue: VideoUploaderUserViewModel(fromUID: fromUID))
    }
    
    
    var body: some View {
        switch vm.state {
        case .idle:
            EmptyView()
        case .loading:
            EmptyView()
        case .failed(_):
            EmptyView()
        case .loaded:
            VStack{
                Image(uiImage: vm.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(lineWidth: 3))
                Text(vm.user.username)
                    .font(.caption)
                
            }.onTapGesture {
                showProfile.toggle()
            }
            
            .sheet(isPresented: $showProfile) {
                ClubberDetailView(image: vm.image, user: vm.user, show: $showProfile)
            }
          
            
            
        }
    }
}


struct ClubberDetailView: View {
    
    let image: UIImage
    let user : User
    @Binding var show: Bool
    
    var body: some View {
        ZStack{
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .padding()
            VStack{
                HStack{
                    Spacer()
                    Button {
                        show = false
                        
                    } label: {
                        Image(systemName: "x.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                    }.padding()

                }
                Spacer()
                Text(user.username)
                    .bold()
                    .frame(width: 280, height: 44)
                    .background(.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
            }
        }
    }
}

//struct VideoUploaderUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoUploaderUserView()
//    }
//}
