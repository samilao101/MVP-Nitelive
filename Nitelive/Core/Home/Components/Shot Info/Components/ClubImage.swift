//
//  ClubImage.swift
//  Nitelive
//
//  Created by Sam Santos on 5/10/22.
//

import SwiftUI

class ImageLoader: ObservableObject {
    
    @Published var image = UIImage(systemName: "building")!
    
    init(clubId: String) {
       getImage(clubId: clubId)
    }
    
    
    
    func getImage(clubId: String) {
        DispatchQueue.main.async {
            self.downloadImage(clubId: clubId) { result in
                switch result {
                case .success(let downloadedImage):
                    self.image = downloadedImage
                case .failure(_):
                    self.getImage(clubId: clubId)
                    break
                }
            }
        }
        
    }
    
    func downloadImage(clubId: String, handler: @escaping(Result<UIImage, Error>)->Void) {
        
        let logoStorage = FirebaseManager.shared.storage.reference().child("LocationImage/\(clubId)/\(clubId).jpeg")

        
        logoStorage.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            print(error.localizedDescription)
              return
          } else {
            let image = UIImage(data: data!)
            guard let newimage = image else { return }
            handler(.success(newimage))
          }

        }
        
    }
    
}

struct ClubImage: View {
 
    enum Shape {
        case circle
        case full
    }
    
    @State var shape: Shape
    @State var imageUrl: String
 
    @StateObject var imageLoader: ImageLoader
    
    init(clubId: String, shape: Shape, imageUrl: String){
        _imageLoader = StateObject(wrappedValue: ImageLoader(clubId: clubId))
        self.shape = shape
        self.imageUrl = imageUrl
    }
    
    var body: some View {
       
        switch shape {
        case .circle:
            Image(uiImage: imageLoader.image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    
                    Circle()
                        .stroke(.white, lineWidth: 4)
                        .blur(radius: 2)
                    
                )
        case .full:
            Image(uiImage: imageLoader.image)
                .resizable()
                .scaledToFill()
                .blur(radius: 6)
                .ignoresSafeArea()
        }
     
            
        
    }
}

//struct ClubImage_Previews: PreviewProvider {
//
//
//
//    static var previews: some View {
//        ClubImage(clubId: "dCU2kVKZHXIlSr04VmEf", shape: .circle)
//    }
//}
