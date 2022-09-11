//
//  SparkFirestore.swift
//  SwiftUISignInWithAppleAndFirebaseDemo
//
//  Created by Alex Nagy on 08/12/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import FirebaseFirestore

struct SparkFirestore {
    
    static func retreiveProfile(uid: String, completion: @escaping (Result<Profile, Error>) -> ()) {
        let reference = Firestore
            .firestore()
            .collection(SparkKeys.CollectionPath.profiles)
            .document(uid)
        getDocument(for: reference) { (result) in
            switch result {
            case .success(let data):
                guard let profile = Profile(documentData: data) else {
                    completion(.failure(SparkAuthError.noProfile))
                    return
                }
                completion(.success(profile))
            case .failure(let err):
                completion(.failure(err))
            }
        }
        
    }
    
    static func mergeProfile(_ data: [String: Any], uid: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        let reference = Firestore
            .firestore()
            .collection(FirebaseConstants.users)
            .document(uid)
        reference.setData(data, merge: true) { (err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(true))
        }
    }
    
    // MARK: - fileprivate
    
    fileprivate static func getDocument(for reference: DocumentReference, completion: @escaping (Result<[String : Any], Error>) -> ()) {
        reference.getDocument { (documentSnapshot, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let documentSnapshot = documentSnapshot else {
                completion(.failure(SparkAuthError.noDocumentSnapshot))
                return
            }
            guard let data = documentSnapshot.data() else {
                completion(.failure(SparkAuthError.noSnapshotData))
                return
            }
            completion(.success(data))
        }
    }
}

