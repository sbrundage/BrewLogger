//
//  StatRow.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/13/26.
//

import SwiftUI

/// A horizontal row of labeled values separated by vertical dividers.
/// Dividers only appear between present items, so a single stat renders cleanly.
struct StatRow: View {
    struct Stat: Identifiable {
        let id = UUID()
        let label: String
        let value: String
    }

    let stats: [Stat]

    var body: some View {
        HStack {
            ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                VStack {
                    Text(stat.label)
                        .fontWeight(.light)
                    Text(stat.value)
                        .fontWeight(.medium)
                } //: VStack
                .frame(maxWidth: .infinity)

                if index < stats.count - 1 {
                    Divider()
                        .frame(width: 0.5, height: 30)
                        .overlay(.secondary)
                }
            } //: ForEach
        } //: HStack
    }
}

#Preview {
    StatRow(stats: [
        .init(label: "Grind Size", value: "18"),
        .init(label: "Time", value: "30s"),
        .init(label: "Yield", value: "40g")
    ])
    .padding()
}
