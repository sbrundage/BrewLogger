//
//  SwiftUIView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/19/26.
//

import SwiftUI

struct BleConnectionView: View {
    let isConnected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                if isConnected {
                    Text("Connected to BLE Scale")
                        .font(.footnote)
                    
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 8, height: 8)
                } else {
                    Text("Not connected to BLE Scale")
                        .font(.footnote)
                }
            } //: HStack
            .foregroundStyle(isConnected ? .green : .red)

            if !isConnected {
                Button("Open Bluetooth Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.footnote)
            }
        } //: VStack
    }
}

#Preview {
    BleConnectionView(isConnected: true)
    BleConnectionView(isConnected: false)
}
