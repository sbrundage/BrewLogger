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
    @State private var pendingEntry: TastingEntry?
    @State private var editingEntry: TastingEntry?

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

            if viewModel.showsChart {
                Section("Taste Over Time") {
                    TasteChartView(points: viewModel.chartPoints)
                }
            }

            Section {
                ForEach(viewModel.entryRows) { row in
                    TastingEntryRow(row: row)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = viewModel.entry(id: row.id) }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteEntry(id: row.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
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
        .sheet(isPresented: $showAddNote, onDismiss: {
            if let pendingEntry {
                viewModel.appendEntry(pendingEntry)
                self.pendingEntry = nil
            }
        }) {
            AddNoteSheet(brewDate: viewModel.brewDate) { entry in
                pendingEntry = entry
            }
        }
        .sheet(item: $editingEntry) { entry in
            AddNoteSheet(brewDate: viewModel.brewDate, editing: entry) { updated in
                viewModel.updateEntry(updated)
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

#Preview("Full") {
    // Brew dated in the past so an added note lands mid-window and charts.
    let brewedAt = Date().addingTimeInterval(-18 * 60)
    let brew = Brew(
        id: UUID().uuidString,
        date: brewedAt,
        coffee: .preview,
        grindSize: 0.6,
        dose: 18,
        yield: 36,
        brewTime: 28,
        method: .pourOver,
        brewTemp: 195,
        tastingEntries: [
            TastingEntry(createdAt: brewedAt, rating: 4, note: "Clean and sweet, nice clarity"),
            TastingEntry(createdAt: brewedAt.addingTimeInterval(8 * 60), rating: 4.5, note: "Acidity opening up, juicy"),
            TastingEntry(createdAt: brewedAt.addingTimeInterval(13 * 60), rating: 3.5, note: "Flattening as it cools")
        ]
    )
    return NavigationStack {
        BrewDetailsFormView(brew: brew)
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
        tastingEntries: []
    )
    return NavigationStack {
        BrewDetailsFormView(brew: sparse)
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}

// Interactive: add notes with ratings and each lands 8 min apart (stub entrySpacing), so the chart builds live.
#Preview("Tasting flow") {
    NavigationStack {
        BrewDetailsFormView(brew: Brew.previewList[0])
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}

