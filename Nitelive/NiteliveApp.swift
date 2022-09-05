//
//  NiteliveApp.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import SwiftUI
import MapKit
import UIKit
import AVKit


@main
struct NiteliveApp: App {
    //why not
    //FirebaseData: The app starts by downloading all the videos metadata uploaded for each club and all the clubs information (name, address etc...)
    
    //UserManager: It also initializes UserManager, which tracks if the User is logged in into Firebase.
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate
    @StateObject var firebaseData = FirebaseData.instance
    @StateObject var userManager = UserManager.instance
    
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
                            
                            if firebaseData.noShotsUploaded {
                                Text("""
                                          NO VIDEOS YET TONIGHT.
                                          
                                          Be the first to upload:
                                              1. Accept location permission.
                                              2. Create an account.
                                              2. Go to a club listed.
                                              3. Wait until the app recognizes you are in.
                                              3. Click on the record button (bottom).
                                          """)
                                .navigationBarHidden(true)
                            } else {
                                MainView(dataService: firebaseData)
                                    .ignoresSafeArea()
                            }
                               
                        }
                        .environmentObject(userManager)
                        .environmentObject(firebaseData)
                        .background(
                            NavigationLink(
                                destination: LazyView(view: {
                                    NotificationShotView(shot: firebaseData.notificationShot!, player: AVPlayer(url: firebaseData.notificationShot!.videoUrl))
                                }),
                                isActive: $firebaseData.showNotificiationShot,
                                label: { EmptyView() }))}
                        .preferredColorScheme(.dark)
                        .onAppear{
                            UserDefaults.standard.setValue("false", forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                        }.navigationViewStyle(StackNavigationViewStyle())
                      
                        
                }
                   
            }
        }
        
    }
}
