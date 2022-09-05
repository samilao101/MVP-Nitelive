//
//  MainView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import SwiftUI
import AVFoundation



struct MainView: View {
    
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
                }.padding(.top, 40)
                Spacer()
            }.sheet(isPresented: $showEmailView) {
                EmailSupportView(supportInfo: RequestToAddClub(latitude: userManager.location?.latitude.description ?? "Not known", longitude: userManager.location?.longitude.description ?? "Not known"))
            }
        }
    }
    
   
    
}

//struct MainView_Previews: PreviewProvider {
//    
//    @StateObject static var firebaseData = FirebaseData(state: .loaded)
//    @StateObject static var userManager = UserManager()
//
//    
//    static var previews: some View {
//        ZStack {
//            switch firebaseData.state {
//            case .idle:
//                Text("Idle...")
//            case .loading:
//                LaunchView()
//                    .ignoresSafeArea()
//            case .failed(let error):
//                Text("\(error.localizedDescription)")
//            case .loaded:
//                NavigationView{
//                    PostButton(clubs: firebaseData.clubs, userLocation: userManager.location, userManager: userManager ) {
//                        MainView(dataService: firebaseData)
//                            .ignoresSafeArea()
//                           
//                    }
//                    .environmentObject(userManager)
//                    .environmentObject(firebaseData)
//                    
//                }
//            }
//        }
//    }
//    
//    
//}