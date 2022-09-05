//
//  ClubMarker.swift
//  Nitelive
//
//  Created by Sam Santos on 6/5/22.
//


import SwiftUI
import AVFoundation


class ThumbnailLoader: ObservableObject {
    
    
    var thumbnailURLs: [URL]?
    
    
    func getClubVideosThumbnails() async -> [UIImage]? {
        

   
            if thumbnailURLs != nil {
                
                do {
                    
                    return try await withThrowingTaskGroup(of: UIImage?.self) { group in

                        
                        var thumbnails = [UIImage]()

                        thumbnails.reserveCapacity(thumbnailURLs!.count)
                        
                        for urlString in thumbnailURLs! {
                            group.addTask {
                                await self.getThumbnailImage(forUrl: urlString)
                            }
                        }
                        
                        for try await image in group {
                            if let image = image {
                                thumbnails.append(image)
                            }
                        }
                        
                       return thumbnails
                        

                   
                        
                      
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
                
                
            } else {
                return nil
            }
        
      
        return nil
      
        
        
    }
    
    func getThumbnailImage(forUrl url: URL) async -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
    
}



struct ClubMarker: View {
    
    var club: Club
    var thumbnailURLs: [URL]?
    
    @Binding var loadedShotThumbnails: Bool
    
    @StateObject private var thumbnailLoader = ThumbnailLoader()
    @State var clubShotImages: [UIImage]? = nil

    
    var body: some View {
        VStack {
            ZStack {
                
                MapBalloon()
                    .frame(width: 100, height: 70)
                    .foregroundColor(.white)
                
                MapBalloon()
                    .frame(width: 90, height: 60)
                    .foregroundColor(.black)
                if clubShotImages == nil {
                    ClubImage(clubId: club.id, shape: .circle, imageUrl: club.clubImageUrl)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .offset(y: -11)
                } else {
                    thumbnailLooper(images: clubShotImages!)
                }
                
                if club.checkedIN ?? 0 > 0 {
                    Text("\(min(club.checkedIN ?? 0, 99))")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 26, height: 18)
                        .background(.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .offset(x: 20, y: -28)
                }
                
            }
            
            Text(club.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }.task {
            if thumbnailURLs != nil {
                thumbnailLoader.thumbnailURLs = thumbnailURLs
                print(1)
               clubShotImages = await thumbnailLoader.getClubVideosThumbnails()
                print(2)
                loadedShotThumbnails = true
            }
        }
        
    }

}

//struct DDGAnnotation_Previews: PreviewProvider {
//    static var previews: some View {
//        DDGAnnotation(location: DDGLocation(record: MockData.location), number: 44)
//    }
//}
