//
//  TasteChartView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/23/26.
//

import Charts
import SwiftUI

struct TasteChartView: View {
    let points: [TasteChartPoint]

    var body: some View {
        Chart(points) { point in
            LineMark(
                x: .value("Min post-brew", point.minutes),
                y: .value("Rating", point.rating)
            )
            .foregroundStyle(BrandColors.accent)
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Min post-brew", point.minutes),
                y: .value("Rating", point.rating)
            )
            .foregroundStyle(BrandColors.accent)
        }
        .chartYScale(domain: 0...5)
        .chartXScale(domain: 0...Double(TastingSession.windowMinutes))
        .frame(height: 160)
        .animation(.easeInOut(duration: 0.8), value: points)
    }
}
