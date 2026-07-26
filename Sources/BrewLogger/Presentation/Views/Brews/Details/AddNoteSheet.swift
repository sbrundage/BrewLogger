//
//  AddNoteSheet.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/21/26.
//

import SwiftUI
import BrewLoggerDomain

struct AddNoteSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ViewModel

    private let onSave: (TastingEntry) -> Void

    init(brewDate: Date, onSave: @escaping (TastingEntry) -> Void) {
        self.viewModel = ViewModel(brewDate: brewDate)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Note", text: $viewModel.note, axis: .vertical)
                        .lineLimit(3...8)

                    TextField("Rating (0–5)", text: $viewModel.rating)
                        .keyboardType(.decimalPad)
                } header: {
                    if let timeMark = viewModel.timeMark {
                        Label(timeMark, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(viewModel.makeEntry())
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

extension AddNoteSheet {
    @MainActor @Observable
    final class ViewModel {
        private let brewDate: Date
        private let openedAt: Date

        var note: String = ""
        var rating: String = ""

        var canSave: Bool {
            !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var timeMark: String? {
            let minutes = Int(openedAt.timeIntervalSince(brewDate) / 60)
            guard (0...TastingSession.windowMinutes).contains(minutes) else { return nil }
            return "\(minutes) min post-brew"
        }

        init(brewDate: Date, openedAt: Date = Date()) {
            self.brewDate = brewDate
            self.openedAt = openedAt
        }

        func makeEntry() -> TastingEntry {
            TastingEntry(createdAt: openedAt, rating: Double(rating), note: note)
        }
    }
}

#Preview {
    let brewedAt = Date().addingTimeInterval(-18 * 60)
    AddNoteSheet(brewDate: brewedAt, onSave: { _ in })
}
