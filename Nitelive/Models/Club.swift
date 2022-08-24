//
//  Club.swift
//  Nitelive
//
//  Created by Sam Santos on 5/5/22.
//

import Foundation
import CoreLocation

struct Club: Identifiable {
 
    let id : String
    let name: String
    let address: String
    let phone: String
    let website: String
    var checkedIN: Int?
    let lat: Double
    let lon: Double
    let clubImageUrl: String
    var location: CLLocation {CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))}
    
    
    init(id: String, data: [String: Any]) {
       
        self.id = id
        name = data[FirebaseConstants.clubName] as? String ?? ""
        address = data[FirebaseConstants.clubAddress] as? String ?? ""
        website = data[FirebaseConstants.clubWebsite] as? String ?? ""
        phone = data[FirebaseConstants.clubPhone] as? String ?? ""
        checkedIN = data[FirebaseConstants.checkedIN] as? Int ?? 0
        lat = data[FirebaseConstants.latitude] as? Double ?? 0
        lon = data[FirebaseConstants.longitude] as? Double ?? 0
        clubImageUrl = data[FirebaseConstants.clubImageUrl] as? String ?? ""
      
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
