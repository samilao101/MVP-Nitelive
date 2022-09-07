//
//  FirebaseData.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import Foundation
import Firebase
import SwiftUI
import AVFoundation

class FirebaseData: ObservableObject {
      
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    @Published var state: State = .idle
    
    @Published var shots = [Shot]()
    @Published var clubs = [Club]()
    @Published var showNotificiationShot = false
    @Published var notificationShot: Shot?
    @Published var noShotsUploaded = true
    
    static let instance = FirebaseData()
    
    init(){
        DispatchQueue.main.async {
            self.getShots()
            self.getClubs()
        }
     
    }
    
    init(state: State){
        self.state = state
    }
    
    private func getShots() {
        
        state = .loading
        FirebaseManager.shared.firestore.collection(FirebaseConstants.locationVideos).addSnapshotListener { query, error in
            
            if let error = error {
                
                print(" ⛔️ Error loading data from Firebase: \(error.localizedDescription)")
                self.state = .failed(error)
                return
            }
    
            query?.documentChanges.forEach({ change in

                switch change.type {
                case .added:
                    self.addShot(change)
                case .modified:
                    self.updateShot(change)
                case .removed:
                    self.removeShot(change)
                }
            })
            
            if self.shots.count > 0 {
                self.noShotsUploaded = false
            }
            
            self.state = .loaded
            
        }
    }
    
    private func getClubs() {
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).addSnapshotListener { query, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            query?.documentChanges.forEach({ change in
               
                switch change.type {
                case .added:
                    self.addClub(change)
                case .modified:
                    self.updateClub(change)
                case .removed:
                    self.removeClub(change)
                }
            })
        }
    }
    
    func getClubVideos(club: Club) -> [Shot] {
        
        let filteredShots = shots.filter { shot in
            shot.clubId == club.id
        }
        return  filteredShots
    }
    
    func getClubVideosThumbnailsUrls(club: Club) -> [URL]? {
        
        var thumbnailsURLs = [URL]()
        
        let filteredShots = shots.filter { shot in
            shot.clubId == club.id
        }
            filteredShots.forEach { shot in
                thumbnailsURLs.append(shot.videoUrl)
            }
        if thumbnailsURLs.isEmpty {
            return nil
        } else {
            return thumbnailsURLs
        }
    }
    
    func getNotificationShot(id: String){
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.locationVideos).document(id).getDocument { snapshot, error in
            if let error = error {
                print("error getting shot from notification:\(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {return}
            self.notificationShot = Shot(data: data as [String: Any])
            self.showNotificiationShot = true
        
        }
    }
    
    
    fileprivate func addShot(_ change: DocumentChange) {
        let data = change.document.data()
        let tempShot = Shot(data: data)
        
        self.shots.append(tempShot)
    }
    
    fileprivate func updateShot(_ change: DocumentChange) {
        let data = change.document.data()
        let tempShot = Shot(data: data)
        
        let id = data[FirebaseConstants.id] as? String ?? ""
        if let index = self.shots.firstIndex(where: { shot in
            shot.id == id
        }) {
            self.shots[index] = tempShot
        }
    }
    
    fileprivate func removeShot(_ change: DocumentChange) {
        let data = change.document.data()
        let id = data[FirebaseConstants.id] as? String ?? ""
        
        if let index = self.shots.firstIndex(where: { shot in
            shot.id == id
        }) {
            self.shots.remove(at: index)
        }
    }
    
    fileprivate func addClub(_ change: DocumentChange) {
        let data = change.document.data()
        let id = change.document.documentID
        
        let tempClub = Club(id: id, data: data)
        self.clubs.append(tempClub)
    }
    
    fileprivate func updateClub(_ change: DocumentChange) {
        let data = change.document.data()
        let id = change.document.documentID
        let tempClub = Club(id: id, data: data)
        
        if let index = self.clubs.firstIndex(where: { club in
            club.id == id
        }) {
            self.clubs[index] = tempClub
        }
    }
    
    fileprivate func removeClub(_ change: DocumentChange) {
        let id = change.document.documentID
        
        if let index = self.clubs.firstIndex(where: { club in
            club.id == id
        }) {
            self.clubs.remove(at: index)
        }
    }
    
}
