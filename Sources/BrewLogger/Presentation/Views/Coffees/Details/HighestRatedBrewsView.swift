//
//  HighestRatedBrewsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/10/26.
//

import SwiftUI
import BrewLoggerDomain

struct HighestRatedBrewsView: View {
    let brews: [Brew]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Highest Rated Brew")
                .font(.headline)
            
            ForEach(brews) { brew in
                VStack(alignment: .leading) {
                    Text(brew.method.title)
                        .underline()

                    StatRow(stats: [
                        .init(label: "Grind Size", value: brew.grindSize.tens),
                        .init(label: "Time", value: "\(brew.brewTime.tens)s"),
                        .init(label: "Yield", value: "\(brew.yield.tens)g")
                    ])
                } //: VStack
            } //: ForEach
        } //: VStack
    }
}

#Preview {
    HighestRatedBrewsView(brews: Brew.previewList)
}
