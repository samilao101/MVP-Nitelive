//
//  ShotLoader.swift
//  Nitelive
//
//  Created by Sam Santos on 5/8/22.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI


class ShotLoader: ObservableObject {
    

    @Published var shots = [Shot]()
    @Published var clubs = [Club]()
        
    let dataService: FirebaseData

    
    var cancellables = Set<AnyCancellable>()
    
    init(dataService: FirebaseData) {
        self.dataService = dataService
        loadShots()
        loadClubs()
    }
    
    func loadShots() {
        dataService.$shots
            .sink { _ in
                
            } receiveValue: { shots in
                self.shots = shots
            }.store(in: &cancellables)

    }
    
    func loadClubs() {
        dataService.$clubs
            .sink { _ in
                
            } receiveValue: { clubs in
                self.clubs = clubs
            }.store(in: &cancellables)
        
    }
    
    
    func getClubById(clubId: String) -> Club {
        
        if let index = clubs.firstIndex(where: { club in
            club.id == clubId
        }) {
            return clubs[index]
        }
        
        return MockData.clubs.club1
        
    }
    
}
