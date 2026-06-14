//
//  BrewDetailsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/13/26.
//

import SwiftUI
import BrewLoggerDomain

struct BrewDetailsView: View {
    let brew: Brew
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                brewInfo
                
                if let roastInfo = brew.coffee.roastInfo {
                    roastInfoView(roast: roastInfo)
                }
            } //: VStack
            .padding(.horizontal)
        }
        .navigationTitle(brew.coffee.name)
    }
    
    private var brewInfo: some View {
        VStack(alignment: .leading) {
            Text("Brew Info")
                .font(.headline)
            
            StatRow(stats: [
                .init(label: "Grind Size", value: brew.grindSize.tens),
                .init(label: "Time", value: "\(brew.brewTime.tens)s"),
                .init(label: "Yield", value: "\(brew.yield.tens)g")
            ])
            
            let stats: [StatRow.Stat] = [
                brew.rating.map { .init(label: "Rating", value: $0.tens) },
                brew.brewTemp.map { .init(label: "Temp", value: "\($0)") },
                .init(label: "Method", value: brew.method.title)
            ].compactMap { $0 }
            
            StatRow(stats: stats)
            
            if let notes = brew.notes {
                Text("Notes:")
                    .fontWeight(.semibold)
                Text(notes)
            }
        } //: VStack
    }
    
    private func roastInfoView(roast: RoastInfo) -> some View {
        let stats: [StatRow.Stat] = [
            roast.date.map { .init(label: "Roast Date", value: $0.shortFormatted) },
            roast.roaster.map { .init(label: "Roaster", value: $0) },
            roast.roastLevel.map { .init(label: "Roast Level", value: $0.title) }
        ].compactMap { $0 }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Roast Info")
                .font(.headline)

            StatRow(stats: stats)
        }
    }
}

#Preview {
    BrewDetailsView(brew: .preview)
}
