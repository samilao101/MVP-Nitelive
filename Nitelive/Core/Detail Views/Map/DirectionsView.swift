//
//  DirectionsView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/24/22.
//

import MapKit
import SwiftUI
import UIKit

struct DirectionsView: View {

  @State private var directions: [String] = []
  @State private var showDirections = false
  @State private var distance = 0.0
  @State private var distanceString = ""
    
    let userLocation: CLLocationCoordinate2D
    let clubLocation: CLLocationCoordinate2D
    

  var body: some View {
    VStack {
        MapDirectionsView(userLocation: userLocation, clubLocation: clubLocation, directions: $directions)
            .cornerRadius(8)

      Button(action: {
        self.showDirections.toggle()
      }, label: {
        Text("Show directions")
              .bold()
            
      })
      .disabled(directions.isEmpty)
      .padding()
        
        Text("\(distanceString) Miles")
     
        
    
    }
    .onAppear{
        let clubLoc = CLLocation(latitude: clubLocation.latitude, longitude: clubLocation.longitude)
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        distance = clubLoc.distance(from: userLoc)/1609
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let number =  numberFormatter.string(from: NSNumber(value: distance)) else { fatalError("Can not get number") }
        distanceString = number
    }
    .sheet(isPresented: $showDirections, content: {
      VStack(spacing: 0) {
        Text("Directions")
          .font(.largeTitle)
          .bold()

        Divider().background(Color(UIColor.systemBlue))

        List(0..<self.directions.count, id: \.self) { i in
          Text(self.directions[i]).padding()
        }
      }
    })
  }
}

struct MapDirectionsView: UIViewRepresentable {

  typealias UIViewType = MKMapView
    
    let userLocation: CLLocationCoordinate2D
    let clubLocation: CLLocationCoordinate2D

  @Binding var directions: [String]

  func makeCoordinator() -> MapViewCoordinator {
    return MapViewCoordinator()
  }

  func makeUIView(context: Context) -> MKMapView {
      
     
      
    let mapView = MKMapView()
    mapView.delegate = context.coordinator

    let region = MKCoordinateRegion(
        center: MapDetails.startingLocation,
      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    mapView.setRegion(region, animated: true)

    let p1 = MKPlacemark(coordinate: userLocation)

    let p2 = MKPlacemark(coordinate: clubLocation)
      
     

    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: p1)
    request.destination = MKMapItem(placemark: p2)
    request.transportType = .automobile

    let directions = MKDirections(request: request)
    directions.calculate { response, error in
      guard let route = response?.routes.first else { return }
      mapView.addAnnotations([p1, p2])
      mapView.addOverlay(route.polyline)
      mapView.setVisibleMapRect(
        route.polyline.boundingMapRect,
        edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
        animated: true)
      self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
    }
    return mapView
  }

  func updateUIView(_ uiView: MKMapView, context: Context) {
  }

  class MapViewCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = .systemBlue
      renderer.lineWidth = 5
      return renderer
    }
  }
}

//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    DirectionsView()
//  }
//}

