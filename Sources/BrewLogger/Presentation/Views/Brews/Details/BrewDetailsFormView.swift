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
        tastingEntries: []
    )
    return NavigationStack {
        BrewDetailsFormView(brew: sparse)
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}
