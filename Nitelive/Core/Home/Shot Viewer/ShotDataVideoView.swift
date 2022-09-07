//
//  MainView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import SwiftUI
import AVFoundation



struct ShotDataVideoView: View {
    
    @State var currentIndex = 0
    @StateObject var loader: ShotLoader
    @State var showRecorder = false
    @State var isGone = false
    @StateObject var clubData: FirebaseData
    @State var showEmailView = false
    
    
    init(dataService: FirebaseData) {
        _loader = StateObject(wrappedValue: ShotLoader(dataService: dataService))
        _clubData = StateObject(wrappedValue: dataService)
    }
    
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
      
        ZStack {
            VerticalPager(userManager: userManager, clubData: clubData, loader: loader, isGone: $isGone)
                .ignoresSafeArea()
                .navigationBarHidden(true)
                .onDisappear{
                   isGone = true
                }
                .onAppear {
                    isGone = false
                }
            
            VStack{
                EmailSupportViewButton(showEmailView: $showEmailView)
                    .padding(.top, 40)
                Spacer()
            }
            .sheet(isPresented: $showEmailView) {
                EmailSupportView(supportInfo: RequestToAddClub(latitude: userManager.location?.latitude.description ?? "Not known", longitude: userManager.location?.longitude.description ?? "Not known"))
            }
        }
        .ignoresSafeArea()
    }
    
   
    
}


