//
//  ProfileView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/11/22.
//

import SwiftUI
import MapKit

struct ClubView: View {
    
    @State private var isCheckedIn = false

    let club: Club
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var vm: UserManager
    @EnvironmentObject var  clubData : FirebaseData

    @State var showChat: Bool = false
    @State var isGone: Bool = false
    
    @State var noShots : Bool = true
  
    var body: some View {
        GeometryReader { geo in
            ScrollView{
            ZStack {
                
                ClubImage(clubId: club.id, shape: .full, imageUrl: club.clubImageUrl)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .ignoresSafeArea()
                  
                    
                VStack {
                    HStack {
                        Spacer()
                        
                        Text(club.name)
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        Spacer()
                            }
                        ZStack {
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(.black)

                                VStack {
                                    Text(club.address)
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Link(destination: URL(string: club.website)!) {
                                        Text(club.website)
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    
                                    Link(destination: URL(string: "tel:\(club.phone.filter("0123456789.".contains))")!) {
                                        Text(club.phone)
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                   
                                }
                                .padding(40)
                                .multilineTextAlignment(.center)
                            
                            }
                            .frame(width: 350, height: 100)
                    
                    if vm.location != nil {
                        DirectionsView(userLocation: vm.location!, clubLocation: CLLocationCoordinate2D(latitude: club.lat, longitude: club.lon))
                        
                            .padding()
                            .cornerRadius(20)
                           
                    } else {
                        MapView(club: club)
                            .frame( height: 300)
                            .padding()
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(.white, lineWidth: 3))
                    }
                    
                    NavigationLink {
                        
                        LazyView {
                            ClubVerticalPager(isGone: $isGone, shots: clubData.getClubVideos(club: club))
                                .ignoresSafeArea()
                        }
                       
                           
                    } label: {
                        HStack{
                        Image(systemName: "video.fill")
                        Text("Videos")
                                .bold()
                        }
                            .frame(width: 280, height: 44)
                            .background(noShots ? .gray : .blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                          
                    }.disabled(noShots)

                        
                    Spacer()
                          }
            
            }
            }
        }.onAppear{
            isGone = false
            if clubData.getClubVideos(club: club).count > 0 {
                self.noShots = false
            }
        }.onDisappear{
            isGone = true
        }
       
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct ClubDetailView_Previews: PreviewProvider {
//
//    static var data: [String: Any] = [
//        FirebaseConstants.clubName: "Club NightClub",
//        FirebaseConstants.clubAddress: "123 Fake St, City, State, 10001",
//        FirebaseConstants.clubPhone: "18001231234",
//        FirebaseConstants.clubWebsite: "www.website.com",
//    ]
//
//    static var previews: some View {
//        ClubDetailView(club: ClubModel(id: "123", data: data, image: UIImage(systemName: "building")))
//    }
//}

fileprivate struct BannerImageView: View {
    
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 160)
            .accessibilityHidden(true)
    }
}


fileprivate struct AddressHStack: View {
    
    var address: String
    
    var body: some View {
        HStack {
            Label(address, systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
