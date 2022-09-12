//
//  HalfModal.swift
//  Nitelive
//
//  Created by Sam Santos on 9/11/22.
//

import Foundation

import SwiftUI


import SwiftUI

class HalfSheetController<Content>: UIHostingController<Content> where Content : View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let presentation = sheetPresentationController {
            presentation.detents = [.medium(), .large()]
            presentation.prefersGrabberVisible = true
            presentation.largestUndimmedDetentIdentifier = .medium
        }
    }
}

struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {

    private let content: Content
    
    @inlinable init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content)
    }
    
    func updateUIViewController(_: HalfSheetController<Content>, context: Context) {
    }
}


enum SheetMode {
    case none
    case quarter
    case half
    case full
}

struct FlexibleSheet<Content: View>: View {
    
    let content: () -> Content
    var sheetMode: Binding<SheetMode>
    
    init(sheetMode: Binding<SheetMode>, @ViewBuilder content: @escaping () -> Content) {
        
        self.content = content
        self.sheetMode = sheetMode
        
    }
    
    private func calculateOffset() -> CGFloat {
        
        switch sheetMode.wrappedValue {
            case .none:
                return UIScreen.main.bounds.height
            case .quarter:
                return UIScreen.main.bounds.height - 100
            case .half:
                return UIScreen.main.bounds.height/2
            case .full:
                return 0
        }
        
    }
    
    var body: some View {
        content()
            .offset(y: calculateOffset())
            .animation(.spring())
            .edgesIgnoringSafeArea(.all)
    }
}
