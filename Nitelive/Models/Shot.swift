//
//  Shot.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import Foundation
import AVFoundation
import SwiftUI


struct Shot: Identifiable {
    
    let id: String
    let email: String
    let fromId: String
    let profileImageUrl: String
    let videoUrl: URL
    let timeStamp: Date
    let clubId: String
    var thumbnail: UIImage?
    
    init(data: [String: Any]) {
        
        self.id = data[FirebaseConstants.id] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.videoUrl = URL(string: data[FirebaseConstants.videoUrl] as? String ?? "")!
        self.clubId = data[FirebaseConstants.clubId] as? String ?? ""
        let timeStampString = data[FirebaseConstants.timestamp] as? String ?? ""
        self.timeStamp = Date().shotDateFromString(dateString: timeStampString)
//        self.thumbnail = getThumbnailImage(forUrl: videoUrl)
        
    }
    
}
