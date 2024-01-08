//
//  ContentView.swift
//  MapKitSwiftUI
//
//  Created by Delstun McCray on 1/8/24.
//

import MapKit
import SwiftUI

struct ContentView: View {
    
    @State private var directions: [String] = []
    @State private var showDirections = false
    @State private var distances: [Double] = []
    var body: some View {
        VStack {
            MapView(directions: $directions, distances: $distances)
            
            Button(action: {
                showDirections.toggle()
            }, label: {
                Text("Show Directions")
            })
            .disabled(directions.isEmpty)
            .padding()
        }
        .sheet(isPresented: $showDirections, content: {
            VStack {
                Text("Direction")
                    .font(.largeTitle.bold())
                    .padding()
                
                Divider()
                    .background(Color.blue)
                
                List {
                    ForEach(0..<self.directions.count, id: \.self) { i in
                        HStack {
                            Text(self.directions[i])
                            
                            Spacer()
                            
                            Text("\(self.roundDistance(meters: distances[i + 1]))")
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding()
                    }
                }
            }
        })
    }
    
    func roundDistance(meters: Double) -> String {
        let feet = meters * 3.28084 // Convert meters to feet
        let miles = feet / 5280.0
        
        if miles < 0.25 {
            return "\(Int(feet)) feet"
        } else if miles >= 1.0 {
            let roundedMiles = (miles * 10).rounded() / 10 // Round to nearest tenth of a mile
            return "\(roundedMiles) miles"
        } else {
            let roundedMiles = miles.rounded()
            return "\(roundedMiles) mile"
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @Binding var directions: [String]
    @Binding var distances: [Double]
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.8590, longitude: -122.8212), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
        
        // MARK: St. Helens
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 45.87527847057365, longitude: -122.81023778547092))
        
        // MARK: Cathlamet
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 46.174148814554194, longitude: -123.38331920264615))
        
        // MARK: Request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        // MARK: Directions
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
            self.distances = route.steps.map { $0.distance }
            mapView.addAnnotations([p1, p2])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 24, left: 30, bottom: 24, right: 30), animated: true)
        }
        
        return mapView
    }
    
    func updateUIView(_ nsView: MKMapView, context: Context) {
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .orange
            renderer.lineWidth = 3
            
            return renderer
        }
    }
}


