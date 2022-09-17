//
//  ListView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/27/22.
//


import SwiftUI

struct ListView: View {


    @State  var clubs : [Club]
    @State  var shots : [Shot]
    @State  var searchText = ""
    @Binding var showListView: Bool
    

    
    var body: some View {
 
            List {
                ForEach(searchResults) { club in
                    NavigationLink {
                        LazyView{
                        ClubView(shots: getClubVideos(club: club), club: club)
                        }

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
                    LazyView {
                    ClubsMapView(clubs: searchResults, shots: shots)
                        .navigationTitle("")
                    }

                } label: {
                    Label("Clubs Map", systemImage: "map.circle")
                        .foregroundColor(.white)
                        .font(.title)
                }


            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showListView.toggle()
                } label: {
                    Label("", systemImage: "arrow.backward")
                        .foregroundColor(.white)
                        .font(.title)
                }

            }
        }
     
   
    }
    
    var searchResults: [Club] {
            if searchText.isEmpty {
                return clubs
            } else {
               return  clubs.filter { $0.name.contains(searchText) }
            }
        }
    
    func getClubVideos(club: Club) -> [Shot] {
        
        let filteredShots = shots.filter { shot in
            shot.clubId == club.id
        }
        return  filteredShots
    }
}

//struct ClubListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView().environmentObject(FirebaseData(state: .loaded))
//    }
//}
