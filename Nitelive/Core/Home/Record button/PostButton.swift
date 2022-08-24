//
//  PostButton.swift
//  Nitelive
//
//  Created by Sam Santos on 5/20/22.
//

import SwiftUI
import MapKit

class PostButtonManager: ObservableObject {
    
    var clubs : [Club]
    var userLocation: CLLocationCoordinate2D?
    @Published var nearClub: Bool = false
    @Published var clubThatIsNear: Club?
    @ObservedObject var userManager: UserManager
    
    
    
    init(clubs: [Club], userLocation: CLLocationCoordinate2D?, userManager: UserManager) {
        self.clubs = clubs
        self.userLocation = userLocation
        _userManager = ObservedObject(wrappedValue: userManager)
        
    }
    
    func checkIfNearAnyClub() {
        
        if let userLocation = userLocation {
            clubs.forEach { club in
                let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let distance = userLoc.distance(from: club.location)
                if distance < 1609*102  //  1609/10 {
                {
                    clubThatIsNear = club
                    nearClub = true
                    userManager.checkInCurrentClub(club: club)
                    print("checked in")
                }
            }
        } else {
            clubThatIsNear = nil
            nearClub = false
            if userManager.currentClub != nil {
                userManager.checkOutCurrentClub()
            }
        }
    }
    
}


struct PostButton<Content: View>: View {
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    let content: Content
    @StateObject var manager: PostButtonManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var firebaseData: FirebaseData
    @State var showLogin = false
    @State var showCamera = false
    @State var showAlert = false
    
    @State var count: Int = 0
    
    init(clubs: [Club], userLocation: CLLocationCoordinate2D?, userManager: UserManager, @ViewBuilder content: () -> Content){
        
        _manager = StateObject(wrappedValue: PostButtonManager(clubs: clubs, userLocation: userLocation, userManager: userManager))
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            
            content
            
            
            VStack{
                
                HStack {
            
                    Spacer()
                        
                    LazyView {
                        NavigationLink(destination:
                                        
                            ListView().environmentObject(firebaseData)
                            .environmentObject(userManager)
                        ) {
                            VStack {
                                Image(systemName: "magnifyingglass.circle")
                                    .font(.system(size: 45))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .padding(.top)
                        }
                    }
                
                    
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Spacer()
                    
                    if manager.nearClub {
                        
                        RecorderButton(club: manager.clubThatIsNear ?? MockData.clubs.club1, image: Image(systemName: "building")) {
                            
                            userManager.currentClub = manager.clubThatIsNear
                            
                            if userManager.currentUser == nil {
                                showLogin = true
                            } else {
                                showCamera = true
                            }
                            
                            
                        }
                    } else {
                        Image(systemName: "circle.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 55))
                            .opacity(0.5)
                            .onTapGesture {
                                showAlert.toggle()
                            }
                    }
                    Spacer()
                    
                    NavigationLink {
                        ProfileView().environmentObject(userManager)
                    } label: {
                        if userManager.isUserCurrentlyLoggedOut {
                            Image(systemName: "person")
                                .foregroundColor(.white)
                                .font(.system(size: 45))
                                .padding()
                                .padding(.trailing)
                        } else {
                            UserNameView(name: userManager.currentUser?.username ?? "username")
                                .padding(.trailing)
                                .padding(.bottom)
                        }

                    }

                }
                
            }
            
        }
        .alert("To upload a video for a club you must be on location and your GPS settings on.", isPresented: $showAlert, actions: {
            Button("Ok", role: .cancel, action: {})
        })
        .fullScreenCover(isPresented: $showCamera, content: {
            RecorderView(showRecorder: $showCamera).environmentObject(userManager)
        })
        .sheet(isPresented: $showLogin, content: {
            LoginView {
                userManager.isUserCurrentlyLoggedOut = false
                userManager.fetchCurrentUser()
                showLogin = false
                showCamera = true
            }.preferredColorScheme(.dark)
        })
      
        .onReceive(timer) { _ in
            count += 1
            
            if count == 30 {
                manager.checkIfNearAnyClub()
                count = 0
            }
        }
    }
    
    
}

//struct PostButton_Previews: PreviewProvider {
//    static var previews: some View {
//        PostButton()
//    }
//}
