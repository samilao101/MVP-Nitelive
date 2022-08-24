//
//  NiteliveApp.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import SwiftUI
import MapKit

@main
struct NiteliveApp: App {
    //why not
    //FirebaseData: The app starts by downloading all the videos metadata uploaded for each club and all the clubs information (name, address etc...)
    
    //UserManager: It also initializes UserManager, which tracks if the User is logged in into Firebase.
    
    @StateObject var firebaseData = FirebaseData()
    @StateObject var userManager = UserManager()
    
    init(){
        UINavigationBar.appearance().tintColor = .white
    }
    
   
    
    var body: some Scene {
        
       //Depending on whether app is able to download all the club videos and club information, the app starts by showing the club's videos on MainView. This is determined by the FirebaseData 'State':
        
        WindowGroup {
            ZStack {
                switch firebaseData.state {
                case .idle:
                    Text("Idle...")
                case .loading:
                    LaunchView()
                        .ignoresSafeArea()
                case .failed(let error):
                    Text("\(error.localizedDescription)")
                case .loaded:
                    NavigationView{
                        PostButton(clubs: firebaseData.clubs, userLocation: userManager.location, userManager: userManager ) {
                            MainView(dataService: firebaseData)
                                .ignoresSafeArea()
                               
                        }
                        .environmentObject(userManager)
                        .environmentObject(firebaseData)
                        
                    }
                        .preferredColorScheme(.dark)
                        
                }
            }
        }
        
    }
}
