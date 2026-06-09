//
//  OriginMapView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct OriginMapView: View {
    @State private var coordinate: CLLocationCoordinate2D?

    let location: String

    var body: some View {
        VStack {
            if let coordinate {
                let region = MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 1_000_000,
                    longitudinalMeters: 3_000_000
                )
                Map(initialPosition: .region(region)) {
                    Marker(location, coordinate: coordinate)
                        .tint(BrandColors.accent)
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(true)
            }
        }
        .task {
            do {
                let placemarks = try await CLGeocoder().geocodeAddressString(location)
                if let clLocation = placemarks.first?.location {
                    coordinate = clLocation.coordinate
                }
            } catch {
                // Geocoding failed — map stays hidden
            }
        }
    }
}

#Preview {
    OriginMapView(location: "Huila, Colombia")
}
