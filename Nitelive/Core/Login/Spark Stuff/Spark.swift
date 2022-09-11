//
//  Spark.swift
//  SwiftUISignInWithAppleAndFirebaseDemo
//
//  Created by Alex Nagy on 08/12/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import SwiftUI
import FirebaseAuth

enum SparkAuthState {
    case undefined, signedOut, signedIn
}

class Spark: ObservableObject {
    
    @Published var isUserAuthenticated: SparkAuthState = .undefined
    @Published var profile: Profile = Profile(uid: "", name: "", email: "")
    
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Auth

    
    func configureFirebaseStateDidChange() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            guard let user = user else {
                print("User is signed out")
                self.isUserAuthenticated = .signedOut
                return
            }
            self.isUserAuthenticated = .signedIn
            print("Successfully authenticated user with uid: \(user.uid)")
            SparkFirestore.retreiveProfile(uid: user.uid) { (result) in
                switch result {
                case .success(let profile):
                    print("Retreived: \(profile)")
                    self.profile = profile
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        })
    }
}

