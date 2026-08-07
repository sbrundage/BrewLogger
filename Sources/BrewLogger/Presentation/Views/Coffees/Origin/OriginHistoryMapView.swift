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
    @State private var viewModel = ViewModel()
    @State private var selection: String?

    var body: some View {
        GlobeMap(locations: viewModel.locations) { selection = $0 }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .task {
                await viewModel.load()
            }
            .sheet(item: Binding(
                get: { selection.flatMap(viewModel.location(id:)) },
                set: { selection = $0?.id }
            )) { location in
                OriginCoffeesSheet(location: location)
            }
    }
}

private struct GlobeMap: UIViewRepresentable {
    // Far enough out to render the earth's curvature as a spinning globe rather than a flat map.
    private static let cameraDistance: CLLocationDistance = 20_000_000

    let locations: [OriginHistoryMapView.ViewModel.CoffeeOriginLocation]
    let onSelect: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
        mapView.pointOfInterestFilter = .excludingAll
        mapView.camera = MKMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(latitude: 10, longitude: 0),
            fromDistance: Self.cameraDistance,
            pitch: 0,
            heading: 0
        )
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.onSelect = onSelect
        context.coordinator.apply(locations, to: mapView)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var onSelect: (String) -> Void

        private var locations: [OriginHistoryMapView.ViewModel.CoffeeOriginLocation] = []
        private var hasRenderedOnce = false

        init(onSelect: @escaping (String) -> Void) {
            self.onSelect = onSelect
        }

        // MapKit drops annotations added before the globe's first render finishes, so hold them until then.
        func apply(_ locations: [OriginHistoryMapView.ViewModel.CoffeeOriginLocation], to mapView: MKMapView) {
            self.locations = locations
            if hasRenderedOnce {
                sync(on: mapView)
            }
        }

        func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
            guard !hasRenderedOnce else { return }
            hasRenderedOnce = true
            sync(on: mapView)
        }

        private func sync(on mapView: MKMapView) {
            let existing = mapView.annotations.compactMap { $0 as? OriginAnnotation }
            let existingIds = Set(existing.map(\.id))
            let newIds = Set(locations.map(\.id))

            mapView.removeAnnotations(existing.filter { !newIds.contains($0.id) })
            mapView.addAnnotations(locations.filter { !existingIds.contains($0.id) }.map(OriginAnnotation.init))
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is OriginAnnotation else { return nil }
            let identifier = "origin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.markerTintColor = UIColor(BrandColors.accent)
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let origin = view.annotation as? OriginAnnotation else { return }
            onSelect(origin.id)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
}

private final class OriginAnnotation: NSObject, MKAnnotation {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String?

    init(_ location: OriginHistoryMapView.ViewModel.CoffeeOriginLocation) {
        self.id = location.id
        self.coordinate = location.coordinate
        self.title = location.title
    }
}

private struct OriginCoffeesSheet: View {
    let location: OriginHistoryMapView.ViewModel.CoffeeOriginLocation

    var body: some View {
        NavigationStack {
            if let coffee = location.singleCoffee {
                CoffeeDetailsView(coffee: coffee)
            } else {
                List(location.coffees) { coffee in
                    NavigationLink {
                        CoffeeDetailsView(coffee: coffee)
                    } label: {
                        Text(coffee.name)
                    }
                }
                .navigationTitle("Coffees")
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    OriginHistoryMapView()
}
