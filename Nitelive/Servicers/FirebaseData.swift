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
    
    //Describes the state of the data retrieval. This determines if any information will be shown to the user.
    
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    @Published var state: State = .idle

    
    //Stores all the clubs videos and club information.
    @Published var shots = [Shot]()
    
    @Published var clubs = [Club]()
    
    static let instance = FirebaseData()
    
    init(){
        DispatchQueue.main.async {
            self.getShots()
            self.getClubs()
        }
     
    }
    
    init(state: State){
        self.state = state
        runTests()
    }
    
    func runTests() {
        
        let testShots = [Shot(data: MockData.shotsData.data)]
        self.shots = testShots
        let testClubs = [Club(id: "123", data: MockData.clubs.data)]
        self.clubs = testClubs
    }
    
    
    /// Downloads the clubs videos
    /// ```
    /// Converts the video meta data into a 'Shot' model and stores in FirebaseData.
    /// ```
    
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
                    let data = change.document.data()
                    let tempShot = Shot(data: data)

                    self.shots.append(tempShot)


                case .modified:
                    let data = change.document.data()
                    let tempShot = Shot(data: data)

                    let id = data[FirebaseConstants.id] as? String ?? ""
                    if let index = self.shots.firstIndex(where: { shot in
                        shot.id == id
                    }) {
                        self.shots[index] = tempShot
                    }


                case .removed:
                    let data = change.document.data()
                    let id = data[FirebaseConstants.id] as? String ?? ""

                    if let index = self.shots.firstIndex(where: { shot in
                        shot.id == id
                    }) {
                        self.shots.remove(at: index)
                    }
                }

            })
            
            print("loaded all documents")
            
            self.state = .loaded
            
            
        }
    }
    
    /// Downloads the clubs data.
    /// ```
    /// Gets all the clubs information as found in Firebase and stores it in 'FirebaseData'.
    /// ```
    
    private func getClubs() {
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).addSnapshotListener { query, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            
            query?.documentChanges.forEach({ change in
               
                switch change.type {
                    
                case .added:
                    let data = change.document.data()
                    let id = change.document.documentID
                    
                    let tempClub = Club(id: id, data: data)
                    self.clubs.append(tempClub)
                    
                case .modified:
                    let data = change.document.data()
                    let id = change.document.documentID
                    let tempClub = Club(id: id, data: data)
                    
                    if let index = self.clubs.firstIndex(where: { club in
                        club.id == id
                    }) {
                        self.clubs[index] = tempClub
                    }
                    
                case .removed:
                    let id = change.document.documentID
                    
                    if let index = self.clubs.firstIndex(where: { club in
                        club.id == id
                    }) {
                        self.clubs.remove(at: index)
                    }
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
    
 
    
}
