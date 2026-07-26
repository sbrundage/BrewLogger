//
//  BrewDetailsFormViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/23/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

// MARK: - Display models

struct DetailRow: Identifiable {
    var id: String { label }
    let label: String
    let value: String
}

struct EntryRow: Identifiable {
    let id: String
    let timeLabel: String?
    let rating: Double?
    let note: String
}

struct TasteChartPoint: Identifiable, Equatable {
    let id: String
    let minutes: Double
    let rating: Double
}

// MARK: - View Model

extension BrewDetailsFormView {
    @MainActor @Observable
    final class ViewModel {
        private let fetchBrew: FetchBrewUseCase
        private let updateBrew: UpdateBrewUseCase

        private(set) var brew: Brew

        var title: String { brew.coffee.name }
        var brewDate: Date { brew.date }

        var brewInfoRows: [DetailRow] {
            var rows = [
                DetailRow(label: "Grind Size", value: brew.grindSize.tens),
                DetailRow(label: "Time", value: brew.brewTime.brewTimeFormatted),
                DetailRow(label: "Yield", value: "\(brew.yield.tens)g"),
                DetailRow(label: "Method", value: brew.method.title)
            ]
            if let rating = brew.rating {
                rows.append(DetailRow(label: "Rating", value: "\(rating.tens) ★"))
            }
            if let temp = brew.brewTemp {
                rows.append(DetailRow(label: "Temp", value: "\(temp)°F"))
            }
            return rows
        }

        var roastInfoRows: [DetailRow] {
            guard let roast = brew.coffee.roastInfo else { return [] }
            return [
                roast.roaster.map { DetailRow(label: "Roaster", value: $0) },
                roast.date.map { DetailRow(label: "Roast Date", value: $0.shortFormatted) },
                roast.roastLevel.map { DetailRow(label: "Roast Level", value: $0.title) }
            ].compactMap { $0 }
        }

        var entryRows: [EntryRow] {
            sortedEntries.map {
                EntryRow(id: $0.id, timeLabel: timeLabel(for: $0), rating: $0.rating, note: $0.note)
            }
        }

        var chartPoints: [TasteChartPoint] {
            sortedEntries.compactMap { entry in
                let mins = minutes(for: entry)
                guard (0...Double(TastingSession.windowMinutes)).contains(mins),
                      let rating = entry.rating else { return nil }
                return TasteChartPoint(id: entry.id, minutes: mins, rating: rating)
            }
        }

        var showsChart: Bool { chartPoints.count >= 2 }

        init(brew: Brew, repository: BrewRepository = RepositoryFactory.dev.brew) {
            self.fetchBrew = FetchBrewUseCase(repository: repository)
            self.updateBrew = UpdateBrewUseCase(repository: repository)
            self.brew = brew
        }

        func refetchBrew() {
            do {
                guard let updated = try fetchBrew.execute(brewId: brew.id) else { return }
                brew = updated
            } catch {
                // TODO: Handle error
            }
        }

        func appendEntry(_ entry: TastingEntry) {
            let updated = brew.replacingEntries(brew.tastingEntries + [entry])
            do {
                try updateBrew.execute(updatedBrew: updated)
                refetchBrew()
            } catch {
                // TODO: Handle error
            }
        }

        private var sortedEntries: [TastingEntry] {
            brew.tastingEntries.sorted { $0.createdAt < $1.createdAt }
        }

        private func minutes(for entry: TastingEntry) -> Double {
            entry.createdAt.timeIntervalSince(brew.date) / 60
        }

        private func timeLabel(for entry: TastingEntry) -> String? {
            let mins = Int(minutes(for: entry))
            if mins < 0 { return nil }
            if mins == 0 { return "At brew" }
            if mins <= TastingSession.windowMinutes { return "\(mins) min post-brew" }
            return nil   // no label past the tasting window
        }
    }
}
