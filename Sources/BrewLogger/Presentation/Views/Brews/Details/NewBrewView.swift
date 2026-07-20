//
//  NewBrewView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/29/26.
//

import SwiftUI
import BrewLoggerDomain

struct NewBrewView: View {
    let brew: Brew
    // Contexts without day grouping opt in to the date.
    var showsDate: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(brew.coffee.name)
                    .font(.system(size: 18))
                
                if let brewImage = brew.method.image {
                    brewImage
                        .font(.system(size: 18))
                }
                
                Spacer()
                
                if let rating = brew.rating {
                    HStack(spacing: 3) {
                        Text("\(rating.tens)")
                        Image(systemName: "star.fill")
                    }
                }
            } //: HStack

            HStack {
                BrewRatioDetailsView(
                    brew: brew,
                    baseFontWeight: .regular,
                    emphasizeFont: .subheadline
                )

                Spacer()

                timestamp
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } //: HStack
        } //: VStack
    }

    private var timestamp: some View {
        HStack(spacing: 0) {
            if showsDate {
                Text(brew.date.monthDay)
                Text(" · ")
            }
            Text(brew.date, style: .time)
        }
    }
}

#Preview {
    NewBrewView(brew: .preview)
}
