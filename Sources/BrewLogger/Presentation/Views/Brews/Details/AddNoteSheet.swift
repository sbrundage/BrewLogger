//
//  AddNoteSheet.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/21/26.
//

import SwiftUI

struct AddNoteSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ViewModel
    @FocusState private var focused: Bool
    
    private let onSave: (String) -> Void

    init(brewDate: Date, onSave: @escaping (String) -> Void) {
        self.viewModel = ViewModel(brewDate: brewDate)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Note", text: $viewModel.note, axis: .vertical)
                        .lineLimit(3...8)
                        .focused($focused)

                    if let timeMark = viewModel.timeMark {
                        Button {
                            viewModel.insertTimeMark()
                            DispatchQueue.main.async { focused = true }
                        } label: {
                            Label("Add \(timeMark)", systemImage: "clock")
                        }
                        .foregroundStyle(BrandColors.accent)
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
                        onSave(viewModel.note)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .presentationDetents([.fraction(0.3)])
    }
}

extension AddNoteSheet {
    @MainActor @Observable
    final class ViewModel {
        private let brewDate: Date
        private let openedAt: Date

        var note: String = ""

        init(brewDate: Date, openedAt: Date = Date()) {
            self.brewDate = brewDate
            self.openedAt = openedAt
        }

        var canSave: Bool {
            !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        // Taste-over-time only makes sense while a cup is still cooling.
        private let markWindowMinutes = 30

        var timeMark: String? {
            let minutes = Int(openedAt.timeIntervalSince(brewDate) / 60)
            guard (0...markWindowMinutes).contains(minutes) else { return nil }
            return "\(minutes) min post-brew"
        }

        func insertTimeMark() {
            guard let timeMark else { return }
            note = note.isEmpty ? "\(timeMark): " : "\(timeMark): \(note)"
        }
    }
}
