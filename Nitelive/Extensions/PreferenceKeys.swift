//
//  PreferenceKeys.swift
//  Nitelive
//
//  Created by Sam Santos on 5/5/22.
//

import Foundation
import SwiftUI
struct indexPreferenceKey: PreferenceKey {
    static var defaultValue: Int = 0
    
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
}
