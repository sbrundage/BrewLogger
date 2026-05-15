//
//  OriginHistoryMapView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import MapKit

struct OriginHistoryMapView: View {
    @State private var viewModel = OriginHistoryMapViewModel()

    var body: some View {
        Map {
            ForEach(viewModel.locations) { location in
                Marker(location.coffee.name, coordinate: location.coordinate)
                    .tint(.cyan)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    OriginHistoryMapView()
}
