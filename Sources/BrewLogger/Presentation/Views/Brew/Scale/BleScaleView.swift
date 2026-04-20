//
//  BleScaleView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/19/26.
//

import Charts
import SwiftUI
import BrewLoggerApplication

struct BleLiveScaleView: View {
    @Binding var yield: String
    @Binding var brewTime: String

    @State private var viewModel = BleScaleViewModel()
    
    private let maxYield: Double = 45
    private let maxBrewTime: Double = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if viewModel.samples.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.08))
                    Text(viewModel.isArmed ? "Pull your shot…" : "Tap to tare and begin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 180)
                .onTapGesture { viewModel.tare() }
            } else {
                Chart(viewModel.samples) { sample in
                    let clampedWeight = min(sample.weight, maxYield)
                    AreaMark(
                        x: .value("Time (s)", sample.elapsed),
                        y: .value("Weight (g)", clampedWeight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Time (s)", sample.elapsed),
                        y: .value("Weight (g)", clampedWeight)
                    )
                    .foregroundStyle(.cyan)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
                .chartXScale(domain: 0...maxBrewTime)
                .chartYScale(domain: 0...maxYield)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { v in
                        AxisGridLine().foregroundStyle(Color.secondary.opacity(0.2))
                        AxisValueLabel {
                            if let g = v.as(Double.self) { Text("\(Int(g))g").font(.caption2) }
                        }
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 110)
            }

            if let reading = viewModel.latestReading {
                HStack(spacing: 6) {
                    Image(systemName: "thermometer.medium")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Ambient")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f°F", reading.temperature))
                        .font(.caption2.weight(.medium))
                    Text("·")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f%% RH", reading.humidity))
                        .font(.caption2.weight(.medium))
                } //: HStack
            }
            
        } //: VStack
        .onChange(of: viewModel.samples.count) {
            if let weight = viewModel.latestReading?.weight {
                yield = String(format: "%.1f", weight)
            }
            if let elapsed = viewModel.samples.last?.elapsed {
                brewTime = String(format: "%.0f", elapsed)
            }
        }
        .onAppear { viewModel.startObserving() }
        .onDisappear { viewModel.stopObserving() }
    }
}

#Preview {
    BleLiveScaleView(yield: .constant(""), brewTime: .constant(""))
        .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
        .padding()
}
