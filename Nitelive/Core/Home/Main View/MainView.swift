//
//  PostButton.swift
//  Nitelive
//
//  Created by Sam Santos on 5/20/22.
//

import SwiftUI
import MapKit

enum Show {
    case showProfile
    case showRecorder
}


struct MainView<Content: View>: View {
    
//    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    let content: Content
    
//    @StateObject var manager: MainViewManager
    
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var firebaseData: FirebaseData
    
    @State var showLogin = false
    @State var showCamera = false
    @State var showAlert = false
    @State var showEmailView = false
    @State var showLoginCamera = false
    @State var sheetModal: SheetMode = .none
    @State var fullSheet: SheetMode = .none
    @State var show : Show = .showProfile
    @State var showListView = false
    @State var showListViewNav = false


    
    @State var count: Int = 0
    
    init( @ViewBuilder content: () -> Content){
        
//        _manager = StateObject(wrappedValue: manager)
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            
            content
            
            clubSearchView
            
            clubRecorderButtonView
            
            profileButtonView
        
            AnimatedLoginView(sheetModal: $sheetModal) {
                sheetModal = .none
                switch show {
                case .showProfile:
                    break
                case .showRecorder:
                    self.showCamera.toggle()
                }
            }
      
            
        }
      
        .background(
            NavigationLink(
                destination: LazyView(view: {
                    ProfileImageView(image: userManager.profileImage!, userName: userManager.currentUser!.username)
                        .environmentObject(userManager)
                }),
                isActive: $userManager.showLogin,
                label: { EmptyView() })
        )
        .background(
            NavigationLink(
                destination: LazyView(view: {
                    ListView(clubs: firebaseData.clubs, shots: firebaseData.shots)
                }),
                isActive: $userManager.showListView,
                label: { EmptyView() })
        )
        .background(
            NavigationLink(destination: RecorderView(showRecorder: $showCamera).environmentObject(userManager).navigationBarHidden(true), isActive: $showCamera, label: { EmptyView() })
        )
        
        .alert("To upload a video you must be on club location. If you are in location to a club not available in our list of clubs , you can request to add it as new club.", isPresented: $showAlert) {
            Button("Request New Club", role: .none, action: {
                showEmailView.toggle()
            })
            Button("Cancel", role: .cancel, action: {})


        }
        
        .sheet(isPresented: $showEmailView) {
            EmailSupportView(supportInfo: RequestToAddClub(latitude: userManager.location?.latitude.description ?? "Not known", longitude: userManager.location?.longitude.description ?? "Not known"))
        }

        
    }
    
    private var clubSearchView: some View {
        VStack{
            HStack {
                Spacer()
               
                Button {
                    userManager.showListView.toggle()
                } label: {
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 45))
                        .foregroundColor(.white)
                     
                }.padding()
                .padding(.top)

                
            }
            Spacer()
        }
    }
    
    private var clubRecorderButtonView: some View {
        BottomBarView(align: .center) {
            if userManager.nearClub {
                RecorderButton(club: userManager.clubThatIsNear ?? MockData.clubs.club1, image: Image(systemName: "building")) {
                    userManager.currentClub = userManager.clubThatIsNear
                    if userManager.currentUser == nil {
                        self.show = .showRecorder
                        self.sheetModal = .quarter
                        self.fullSheet = .full
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
         
        }
    }
    
    private var profileButtonView: some View {
        BottomBarView(align: .trailing) {
            Button {
                self.show = .showProfile
                self.sheetModal = .quarter
                self.fullSheet = .full
            } label: {
                if userManager.currentUser == nil {
                    Image(systemName: "person.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 35))
                } else {
                    UserNameView(name: userManager.currentUser?.username ?? "username")
                        .onTapGesture {
                            userManager.showLogin.toggle()
                        }
                    
                }
            }

        }
    }
    
    // MARK: - Activity Indicator
    @State private var activityIndicatorInfo = SparkUIDefault.activityIndicatorInfo

    func startActivityIndicator(message: String) {
        activityIndicatorInfo.message = message
        activityIndicatorInfo.isPresented = true
    }

    func stopActivityIndicator() {
        activityIndicatorInfo.isPresented = false
    }

    func updateActivityIndicator(message: String) {
        stopActivityIndicator()
        startActivityIndicator(message: message)
    }
    
    // MARK: - Alert
    @State private var alertInfo = SparkUIDefault.alertInfo
    
    func presentAlert(title: String, message: String, actionText: String = "Ok", actionTag: Int = 0) {
        alertInfo.title = title
        alertInfo.message = message
        alertInfo.actionText = actionText
        alertInfo.actionTag = actionTag
        alertInfo.isPresented = true
    }
    
    func executeAlertAction() {
        switch alertInfo.actionTag {
        case 0:
            print("No action alert action")
            
        default:
            print("Default alert action")
        }
    }
    
    private func startLogin(data: [String: Any])  {
    
    }
    
    
}

//struct PostButton_Previews: PreviewProvider {
//    static var previews: some View {
//        PostButton()
//    }
//}
