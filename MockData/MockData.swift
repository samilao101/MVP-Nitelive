//
//  MockData.swift
//  Nitelive
//
//  Created by Sam Santos on 5/10/22.
//

import Foundation

struct MockData {
    
    
    static let shared = MockData()
    let videoUrl: URL
    let clubImageUrl: URL
    let profileImageURL: URL
    
    init() {
        
        let videoFilePath = Bundle.main.path(forResource: "sampleShot", ofType: "mp4")
        self.videoUrl = URL(fileURLWithPath: videoFilePath!)
        
        let profileImagePath = Bundle.main.path(forResource: "sampleProfileImage", ofType: "jpeg")
        self.profileImageURL = URL(fileURLWithPath: profileImagePath!)
        
        let clubImagePath = Bundle.main.path(forResource: "SampleClubImage", ofType: "jepg")
        self.clubImageUrl = URL(fileURLWithPath: clubImagePath!)
        
        
    }
    
    
    struct clubs {
        static var data: [String: Any] = [
               FirebaseConstants.clubName: "Night Club",
               FirebaseConstants.clubAddress: "123 Fake St, City, State, 10001",
               FirebaseConstants.clubPhone: "18001231234",
               FirebaseConstants.clubWebsite: "www.website.com",
               FirebaseConstants.checkedIN: 0,
               FirebaseConstants.latitude: 0,
               FirebaseConstants.longitude: 0
        ]
       
     
        static var club1: Club {
            return Club(id: "123", data: data)
        }
        
        
        
    }
    
    struct users {
        
        static var data: [String: Any] = [
        
            FirebaseConstants.uid : "123",
            FirebaseConstants.email : "user1@gmail.com",
            FirebaseConstants.profileImageUrl : "image.com",
            FirebaseConstants.username : "user1"
            
        
        ]
       
        static var user1: User {
            return User(data: data)
        }
     
        
    }
    
    
    struct shotsData {
        
        static var data: [String: Any] = [
        
            FirebaseConstants.id : "123",
            FirebaseConstants.email: "sampleEmail@gmail.com",
            FirebaseConstants.fromId: "KNWDNB1232",
            FirebaseConstants.profileImageUrl:"https://picsum.photos/200",
            FirebaseConstants.videoUrl: "https://firebasestorage.googleapis.com:443/v0/b/tonight-2081c.appspot.com/o/LocationVideos%2Fwcj7I4Bsq5lnNHb2euJe%2F694E645A-3B06-4E9A-9E5B-D1AEF58818A1?alt=media&token=c211ef90-72a1-4e8c-9f5b-52778feed51a",
            FirebaseConstants.clubId : "ABC",
            FirebaseConstants.timestamp: "06-14-2022 11:05:35",
        
            
        ]
        
        
    }
    
    
 
}
