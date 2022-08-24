//
//  LazyView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/26/22.
//

import Foundation
import SwiftUI
struct LazyView <T: View>: View {
    var view: () -> T
    var body: some View {
        self.view()
    }
    
}
