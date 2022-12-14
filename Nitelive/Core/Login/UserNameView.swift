//
//  UserNameView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/23/22.
//

import SwiftUI

struct UserNameView: View {
    
    let name: String
    
    init(name: String){
        self.name = name
        print("Initializing profile view")
    }
    
    var body: some View {
        Text(name)
            .font(.headline)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                    .foregroundColor(.white)
                    
            )
      

    }
}

struct UserNameView_Previews: PreviewProvider {
    static var previews: some View {
        UserNameView(name: "Sam ")
    }
}
