//
//  SwiftUIView.swift
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
        (Text("\(brew.dose.tens)g").fontWeight(baseFontWeight) +
         Text(" : ").fontWeight(.light) +
         Text("\(brew.yield.tens)g").fontWeight(baseFontWeight) +
         Text(" in ").fontWeight(.light) +
         Text("\(brew.brewTime.tens)s").fontWeight(baseFontWeight))
        .font(emphasizeFont)
    }
}

#Preview {
    BrewRatioDetailsView(brew: .preview, baseFontWeight: .medium, emphasizeFont: .headline)
}
