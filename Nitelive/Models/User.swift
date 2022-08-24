//
//  User.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



struct User: Codable, Identifiable {
    var id: String {uid}
    let uid, email, profileImageUrl, username: String
    
    init(data: [String: Any]) {
        
        uid = data[FirebaseConstants.uid] as? String ?? ""
        email = data[FirebaseConstants.email] as? String ?? ""
        profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        username = data[FirebaseConstants.username] as? String ?? ""
        
    }
    
    
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
          guard let label = label else { return nil }
          return (label, value)
        }).compactMap { $0 })
        return dict
     
      }
}
