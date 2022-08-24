//
//  ClubMarker.swift
//  Nitelive
//
//  Created by Sam Santos on 6/5/22.
//


import SwiftUI
import AVFoundation



struct ClubMarker: View {
    
    var club: Club
    @State var clubShotImages: [UIImage]?
    var thumbnailURLs: [URL]?

    
    var body: some View {
        VStack {
            ZStack {
                
                MapBalloon()
                    .frame(width: 100, height: 70)
                    .foregroundColor(.white)
                
                MapBalloon()
                    .frame(width: 90, height: 60)
                    .foregroundColor(.black)
//                if clubShotImages == nil {
                    ClubImage(clubId: club.id, shape: .circle, imageUrl: club.clubImageUrl)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .offset(y: -11)
//                } else {
//                    thumbnailLooper(images: clubShotImages!)
//                }
                
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
        }.onAppear{
//            clubShotImages = self.getClubVideosThumbnails()
        }
        
    }
    
    func getClubVideosThumbnails() -> [UIImage]? {
        
        var thumbnails = [UIImage]()

   
            if thumbnailURLs != nil {
                thumbnailURLs?.forEach({ url in
                    if let thumbnail = self.getThumbnailImage(forUrl: url) {
                        thumbnails.append(thumbnail)
                    }
                })
            }
        
      
        
        if thumbnails.isEmpty {
            return nil
        } else {
            print(thumbnails.count)

            return thumbnails
        }
        
        
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
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

//struct DDGAnnotation_Previews: PreviewProvider {
//    static var previews: some View {
//        DDGAnnotation(location: DDGLocation(record: MockData.location), number: 44)
//    }
//}
