//
//  SpinnableOriginHistoryMapView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/26/26.
//
//  Experimental alternative to OriginHistoryMapView: an MKMapView wrapper whose vertical
//  drags pass through to a parent ScrollView while horizontal drags spin the globe.
//  Kept separate so the SwiftUI-Map version stays available as a fallback.

import SwiftUI
import MapKit
import BrewLoggerDomain

struct SpinnableOriginHistoryMapView: View {
    @State private var viewModel = OriginHistoryMapView.ViewModel()
    @State private var selection: String?

    var body: some View {
        GlobeMapRepresentable(locations: viewModel.locations) { id in
            selection = id
        }
        // The map has no intrinsic height; without this it collapses to nothing in a ScrollView.
        .frame(height: 320)
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
            OriginCoffeesListSheet(coffees: location.coffees)
        }
    }
}

private struct OriginCoffeesListSheet: View {
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
    SpinnableOriginHistoryMapView()
}

// MARK: - MKMapView bridge

private struct GlobeMapRepresentable: UIViewRepresentable {
    // Tunables — camera framing and how fast a horizontal drag spins the globe.
    private static let cameraDistance: CLLocationDistance = 20_000_000
    private static let spinSensitivity: Double = 1.0

    let locations: [OriginHistoryMapView.ViewModel.CoffeeOriginLocation]
    let onSelect: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(spinSensitivity: Self.spinSensitivity, onSelect: onSelect)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView

        // Satellite is the only configuration that renders the true sphere zoomed out.
        mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
        mapView.pointOfInterestFilter = .excludingAll

        // Kill built-in scroll so vertical drags reach the parent ScrollView; horizontal spin is manual.
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = true

        mapView.camera = MKMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(latitude: 10, longitude: 0),
            fromDistance: Self.cameraDistance,
            pitch: 0,
            heading: 0
        )

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.delegate = context.coordinator
        mapView.addGestureRecognizer(pan)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let existing = mapView.annotations.compactMap { $0 as? OriginAnnotation }
        let existingIds = Set(existing.map(\.id))
        let newIds = Set(locations.map(\.id))

        mapView.removeAnnotations(existing.filter { !newIds.contains($0.id) })
        mapView.addAnnotations(
            locations.filter { !existingIds.contains($0.id) }.map(OriginAnnotation.init)
        )
    }

    final class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        private let spinSensitivity: Double
        private let onSelect: (String) -> Void

        private var lastTranslationX: CGFloat = 0

        weak var mapView: MKMapView?

        init(spinSensitivity: Double, onSelect: @escaping (String) -> Void) {
            self.spinSensitivity = spinSensitivity
            self.onSelect = onSelect
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let mapView else { return }
            switch gesture.state {
            case .began:
                lastTranslationX = 0
            case .changed:
                let translationX = gesture.translation(in: mapView).x
                let delta = translationX - lastTranslationX
                lastTranslationX = translationX

                let distance = mapView.camera.centerCoordinateDistance
                let metersPerPoint = distance / Double(mapView.bounds.width)
                let degreesPerPoint = metersPerPoint / 111_320.0

                let camera = mapView.camera
                var center = camera.centerCoordinate
                center.longitude = wrapped(center.longitude - Double(delta) * degreesPerPoint * spinSensitivity)
                camera.centerCoordinate = center
                mapView.setCamera(camera, animated: false)
            default:
                break
            }
        }

        // Only claim horizontal-dominant drags; vertical drags fail here and fall through to the ScrollView.
        func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
            guard let pan = gesture as? UIPanGestureRecognizer, let mapView else { return true }
            let velocity = pan.velocity(in: mapView)
            return abs(velocity.x) > abs(velocity.y)
        }

        func gestureRecognizer(
            _ gesture: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            other is UIPinchGestureRecognizer
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

        private func wrapped(_ longitude: CLLocationDegrees) -> CLLocationDegrees {
            var value = longitude
            if value > 180 { value -= 360 }
            if value < -180 { value += 360 }
            return value
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
