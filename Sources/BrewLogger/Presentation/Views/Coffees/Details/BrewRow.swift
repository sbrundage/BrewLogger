//
//  BrewRow.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/13/26.
//

import SwiftUI
import BrewLoggerDomain

struct BrewRow: View {
    let brew: Brew
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                dateView
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let brewImage = brew.method.image {
                    brewImage
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let rating = brew.rating {
                    Text("\(rating.tens)")
                        .font(.subheadline)

                    Image(systemName: "star.fill")
                        .font(.caption)
                }
            } //: HStack

            BrewRatioDetailsView(brew: brew, baseFontWeight: .regular, emphasizeFont: .subheadline)
        } //: VStack
    }

    var dateView: some View {
        HStack(spacing: 0) {
            Text(brew.date.monthDay)
            Text(" · ")
            Text(brew.date, style: .time)
        }
    }
}

#Preview {
    BrewRow(brew: .preview)
}
