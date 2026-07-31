//
//  OriginHistoryMapView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import MapKit
import BrewLoggerDomain

struct OriginHistoryMapView: View {
    // Far enough out to render the earth's curvature as a spinning globe rather than a flat map.
    private static let globeCamera = MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: 10, longitude: 0),
        distance: 20_000_000
    )

    @State private var viewModel = ViewModel()
    @State private var selection: String?

    var body: some View {
        Map(initialPosition: .camera(Self.globeCamera), selection: $selection) {
            ForEach(viewModel.locations) { location in
                Marker(location.title, coordinate: location.coordinate)
                    .tint(BrandColors.accent)
                    .tag(location.id)
            }
        }
        .mapStyle(.hybrid(
            elevation: .realistic,
            pointsOfInterest: .excludingAll
        ))
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.load()
        }
        .sheet(item: Binding(
            get: { selection.flatMap(viewModel.location(id:)) },
            set: { selection = $0?.id }
        )) { location in
            OriginCoffeesSheet(coffees: location.coffees)
        }
    }
}

private struct OriginCoffeesSheet: View {
    let coffees: [Coffee]

    var body: some View {
        NavigationStack {
            List(coffees) { coffee in
                NavigationLink {
                    CoffeeDetailsView(coffee: coffee)
                } label: {
                    Text(coffee.name)
                }
            }
            .navigationTitle("Coffees")
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    OriginHistoryMapView()
}
