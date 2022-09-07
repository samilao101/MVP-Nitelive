//
//  EmailSupportViewButton.swift
//  Nitelive
//
//  Created by Sam Santos on 9/6/22.
//

import SwiftUI

struct EmailSupportViewButton: View {
    
    @Binding var showEmailView: Bool
    
    var body: some View {
        HStack{
            Spacer()
            Button {
                showEmailView.toggle()
            } label: {
                Label {
                    Text("New Club Request")
                } icon: {
                    Image(systemName: "paperplane.fill")
                }
                .font(.system(size: 16))
                .foregroundColor(.white)

            }

            Spacer()
        }
    }
}


