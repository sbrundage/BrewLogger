//
//  BrewDetailsFormView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/20/26.
//

import SwiftUI
import BrewLoggerDomain
import BrewLoggerApplication

struct BrewDetailsFormView: View {
    @State private var viewModel: ViewModel
    @State private var showEditSheet = false
    @State private var showAddNote = false

    init(brew: Brew) {
        self.viewModel = ViewModel(brew: brew)
    }

    var body: some View {
        List {
            Section("Brew Info") {
                ForEach(viewModel.brewInfoRows) { row in
                    LabeledContent(row.label, value: row.value)
                }
            }

            Section {
                if let notes = viewModel.notes {
                    Text(notes)
                }
            } header: {
                HStack {
                    Text("Notes")
                    Spacer()
                    Button {
                        showAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundStyle(BrandColors.accent)
                } //: HStack
            }

            if !viewModel.roastInfoRows.isEmpty {
                Section("Roast Info") {
                    ForEach(viewModel.roastInfoRows) { row in
                        LabeledContent(row.label, value: row.value)
                    }
                }
            }
        }
        .navigationTitle(viewModel.title)
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showEditSheet = true }
            }
        }
        .sheet(isPresented: $showAddNote) {
            AddNoteSheet(brewDate: viewModel.brewDate) { note in
                viewModel.appendNote(note)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                SaveBrewView(brewToEdit: viewModel.brew) {
                    viewModel.refetchBrew()
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showEditSheet = false }
                    }
                }
            }
            .interactiveDismissDisabled()
        }
    }
}

// MARK: - Detail View Model

struct DetailRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

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

        var notes: String? {
            guard let notes = brew.notes, !notes.isEmpty else { return nil }
            return notes
        }
        
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

        func appendNote(_ text: String) {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            let combined = [brew.notes, trimmed]
                .compactMap { $0?.isEmpty == false ? $0 : nil }
                .joined(separator: "\n\n")

            let updated = brew.replacingNotes(combined)
            do {
                try updateBrew.execute(updatedBrew: updated)
                brew = updated
            } catch {
                // TODO: Handle error
            }
        }
    }
}

// MARK: - Local helpers

private extension Brew {
    func replacingNotes(_ notes: String?) -> Brew {
        Brew(
            id: id, date: date, coffee: coffee,
            grindSize: grindSize, dose: dose, yield: yield,
            brewTime: brewTime, method: method, brewTemp: brewTemp,
            rating: rating, notes: notes
        )
    }
}

#Preview("Full") {
    NavigationStack {
        BrewDetailsFormView(brew: .preview)
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}

#Preview("Sparse") {
    let sparse = Brew(
        id: UUID().uuidString,
        date: Date(),
        coffee: Coffee(id: UUID().uuidString, name: "El Puente", originInfo: nil, roastInfo: nil, process: nil),
        grindSize: 3.5,
        dose: 18,
        yield: 36,
        brewTime: 28,
        method: .pourOver,
        brewTemp: nil,
        rating: nil,
        notes: nil
    )
    return NavigationStack {
        BrewDetailsFormView(brew: sparse)
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}
