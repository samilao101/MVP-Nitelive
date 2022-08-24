//
//  ClubChatMessage.swift
//  Nitelive
//
//  Created by Sam Santos on 5/26/22.
//


import Foundation
import FirebaseFirestoreSwift

struct ClubChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toClub, currentClubId, text: String
    let timestamp: Date
}
