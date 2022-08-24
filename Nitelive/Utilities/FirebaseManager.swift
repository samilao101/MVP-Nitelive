//
//  FirebaseManager.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: User?
    
    static let shared = FirebaseManager()
    
    let homeIP: String = "10.0.0.96"
    let coffeeShopIp: String = "10.1.182.196"

    
    override init() {
        FirebaseApp.configure()

     
                
////        Auth.auth().useEmulator(withHost: "10.0.0.96", port: 9099)
////        Storage.storage().useEmulator(withHost: "10.0.0.96", port: 9199)
//        Storage.storage().useEmulator(withHost: homeIP, port: 9199)
//
//        let settings = Firestore.firestore().settings
//        settings.host = "\(homeIP):8085"
//        settings.isPersistenceEnabled = false
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        self.firestore.settings.isPersistenceEnabled = false
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
//
//
        
    }
    
}

