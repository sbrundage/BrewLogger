//
//  BrewRatioDetailsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/10/26.
//

import SwiftUI
import BrewLoggerDomain

struct BrewRatioDetailsView: View {
    let brew: Brew
    let baseFontWeight: Font.Weight
    let emphasizeFont: Font

    var body: some View {
        HStack(spacing: 0) {
            Text("\(brew.dose.tens)g").fontWeight(baseFontWeight)
            Text(" : ").fontWeight(.light).foregroundStyle(.secondary)
            Text("\(brew.yield.tens)g").fontWeight(baseFontWeight)
            Text(" in ").fontWeight(.light).foregroundStyle(.secondary)
            Text(brew.brewTime.brewTimeFormatted).fontWeight(baseFontWeight)
        }
        .font(emphasizeFont)
    }
}

#Preview {
    BrewRatioDetailsView(brew: .preview, baseFontWeight: .medium, emphasizeFont: .headline)
}
