//
//  BleScaleView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/19/26.
//

import SwiftUI
import BrewLoggerApplication

struct BleScaleView: View {
    @State private var viewModel = BleScaleViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BleScaleView()
        .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}
