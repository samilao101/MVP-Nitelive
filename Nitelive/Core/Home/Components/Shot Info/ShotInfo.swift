//
//  ClubInfo.swift
//  Nitelive
//
//  Created by Sam Santos on 5/10/22.
//

import SwiftUI

struct ShotInfo<Content: View>: View {
    
    let content: Content
    var club: Club
    let timeStamp: Date
    let uploaderUID: String
    @StateObject var user: UserManager
    @StateObject var clubData: FirebaseData
    
    @State var angle: Double = 0.0
    let timer = Timer.publish(every: 0.020, on: .main, in: .common).autoconnect()
    
    
    init(club: Club, userManager: UserManager, clubData: FirebaseData, uploaderUID: String, timeStamp: Date, @ViewBuilder content: () -> Content){
        self.content = content()
        self.club = club
        self._user = StateObject(wrappedValue: userManager)
        self._clubData = StateObject(wrappedValue: clubData)
        self.uploaderUID = uploaderUID
        self.timeStamp = timeStamp
        
    }
    
    var body: some View {
        ZStack {
            
            content
            
            VStack {
                
                HStack{
                    
                    VStack{
                            LazyView {
                                NavigationLink {
                                    ClubView(club: club)
                                        .environmentObject(user)
                                        .environmentObject(clubData)
                                } label: {
                                    ZStack{
                                        ClubCircleNameText(radius: 80, text: club.name)
                                            .rotationEffect(.degrees(0))
                                        ZStack{
                                        ClubImage(clubId: club.id, shape: .circle, imageUrl: club.clubImageUrl)
                                        Image(systemName: "circle.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .rotationEffect(Angle(degrees: angle))
                                        .animation(.easeIn, value: angle)
                                    .onReceive(timer) { _ in
                                       angle += 1
                                        
                                    }
                                }
                            }
                        VideoUploaderUserView(fromUID: uploaderUID)
                        Spacer()
                        TimeStampView(date: timeStamp)
                            .padding(.bottom, 50)
                    }
                    Spacer()
                }
                .padding(.top, 40)
                
                Spacer()
                
            }
            
        }
        .navigationBarHidden(true)
        
    }
}

//struct ClubInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        ShotInfo(club: MockData.clubs.club1) {
//            Text("")
//        }
//    }
//}
