//
//  ListView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/27/22.
//


import SwiftUI

struct ListView: View {
    
    @EnvironmentObject var  listOfClubsModel : FirebaseData
    @EnvironmentObject var  userManager : UserManager
    @State private var clubs = [Club]()
    
    @State private var searchText = ""
    
    init(){
        print("Initializing listview")
    }
    
    var body: some View {
 
            List {
                ForEach( searchResults) { club in
                    NavigationLink {
                        ClubView(club: club)
                            .environmentObject(userManager)
                            .environmentObject(listOfClubsModel)
                    } label: {
                        CellView(club: club)
                    }

                }.listRowBackground(Color.black)
                    .background(Color.black)
            }
        
        .searchable(text: $searchText)
        .navigationTitle("Clubs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ClubsMapView(clubs: searchResults)
                        .environmentObject(userManager)
                        .environmentObject(listOfClubsModel)
                        .navigationTitle("")

                } label: {
                    Label("Clubs Map", systemImage: "map.circle")
                        .foregroundColor(.white)
                        .font(.title)
                }


            }
        }
     
   
    }
    
    var searchResults: [Club] {
            if searchText.isEmpty {
                return listOfClubsModel.clubs
            } else {
               return listOfClubsModel.clubs.filter { $0.name.contains(searchText) }
            }
        }
}

struct ClubListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView().environmentObject(FirebaseData(state: .loaded))
    }
}
