//
//  BottomBarView.swift
//  Nitelive
//
//  Created by Sam Santos on 9/5/22.
//

import SwiftUI

struct BottomBarView<T: View>: View {
    
    enum Align {
        case leading
        case center
        case trailing
    }
    
    let content: T
    let align: Align
    
    init(align: Align, @ViewBuilder content: () -> T){
        self.align = align
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                switch align {
                case .leading:
                    
                    content
                    Spacer()
                    
                case .center:
                    
                    Spacer()
                    content
                    Spacer()
                
                case .trailing:
                
                    Spacer()
                    content
                }
            }
            .padding()
        }
    }
}






struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView(align: .leading) {
            Text("Samil")
                .font(.headline)
                .foregroundColor(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                        .foregroundColor(.white)
                        
                )
        }
    }
}
