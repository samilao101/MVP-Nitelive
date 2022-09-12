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
import GoogleSignIn


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
    
   
//    @State var userName = ""
//    @State var image: UIImage? = nil
//    @State var showCam = true
//    
    var body: some Scene {
        
       //Depending on whether app is able to download all the club videos and club information, the app starts by showing the club's videos on MainView. This is determined by the FirebaseData 'State':
        
        WindowGroup {
//            Text("Hello")
//                .fullScreenCover(isPresented: $showCam) {
//                    SelfieUserNameView(showCam: $showCam, userName: $userName, capturedImaged: $image)
//                }
            ZStack {
                switch firebaseData.state {
                case .idle:
                    IdleView()
                case .loading:
                    LaunchView()
                        .ignoresSafeArea()
                case .failed(let error):
                    ErrorView(errorTextInfo: error.localizedDescription)
                case .loaded:
                    NavigationView{
                        MainView(clubs: firebaseData.clubs, userLocation: userManager.location, userManager: userManager ) {

                            if firebaseData.noShotsUploaded {
                               NoVideosDataView()

                            } else {
                              ShotDataVideoView(dataService: firebaseData)
                            }
                        }
                        .environmentObject(userManager)
                        .environmentObject(firebaseData)}
                        .preferredColorScheme(.dark)
                        .background(
                            NavigationLink(
                                destination: LazyView(view: {
                                    NotificationShotView(shot: firebaseData.notificationShot!, player: AVPlayer(url: firebaseData.notificationShot!.videoUrl))
                                }),
                                isActive: $firebaseData.showNotificiationShot,
                                label: { EmptyView() }))
//                        .onOpenURL { url in
//                          GIDSignIn.sharedInstance.handle(url)
//                        }
//                        .onAppear{
////                            GIDSignIn.sharedInstance.signOut()
//                            SparkAuth.logout { result in
//
//                            }
//                        }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
