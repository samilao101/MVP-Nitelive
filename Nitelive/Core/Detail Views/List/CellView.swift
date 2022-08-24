//
//  CellView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/27/22.
//

import Foundation
import SwiftUI

struct CellView: View {
    let club: Club
    
    @State var usersCheckedIn = [User]()
   
    
    
    var body: some View {
        
        HStack{
            ClubImage(clubId: club.id, shape: .circle, imageUrl: club.clubImageUrl )
            VStack(alignment: .leading) {
                Text(club.name)
                    .font(.system(size: 22))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                ScrollView{
                HStack{
                    if club.checkedIN! > 0 {
                        PreviewCount(number: club.checkedIN! )
                    }
                }.padding(3)
                }
            }
            
        }
        
    }
    
  
   
}

struct PreviewCount: View {
    
    var number: Int
    
    var body: some View {
        
        HStack {
            Text("\(String(number))+")
                .bold()
        }
    
    }
    
    
}
