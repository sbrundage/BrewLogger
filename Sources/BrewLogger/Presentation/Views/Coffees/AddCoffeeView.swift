//
//  AddCoffeeView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/1/26.
//

import SwiftUI
import BrewLoggerDomain

struct AddCoffeeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AddCoffeeViewModel()

    @FocusState private var focus: Field?

    var body: some View {
        Form {
            requiredSection
            optionalSection

            Button {
                do { try viewModel.saveCoffee(); dismiss() }
                catch { /* TODO: Handle error */ }
            } label: {
                Text("Save Coffee")
            }
            .foregroundStyle(viewModel.canSave ? .cyan : .secondary)
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.canSave)
        }
        .navigationTitle("New Coffee")
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Button { focus = focus?.previous } label: {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(focus?.previous == nil)

                    Button { focus = focus?.next } label: {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(focus?.next == nil)

                    Spacer()

                    Button("Done") { focus = nil }
                }
            }
        }
    }

    private var requiredSection: some View {
        Section("Required") {
            TextField("Coffee Name", text: $viewModel.newCoffee.name)
                .focused($focus, equals: .name)
        }
    }

    private var optionalSection: some View {
        Section("Optional") {
            TextField("Roaster", text: $viewModel.newCoffee.roaster)
                .focused($focus, equals: .roaster)

            ExpandablePickerRow(
                title: viewModel.newCoffee.roastLevel?.title ?? "Roast Level",
                isSelected: viewModel.newCoffee.roastLevel != nil,
                isExpanded: $viewModel.showRoastLevelPicker
            ) {
                ItemPickerView(
                    items: [RoastLevel.light, .medium, .dark],
                    selectedItem: viewModel.newCoffee.roastLevel
                ) { level in
                    viewModel.newCoffee.roastLevel = level
                    viewModel.showRoastLevelPicker = false
                }
            }

            ExpandablePickerRow(
                title: viewModel.newCoffee.roastDate?.shortFormatted ?? "Roast Date",
                isSelected: viewModel.newCoffee.roastDate != nil,
                isExpanded: $viewModel.showRoastDatePicker
            ) {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.newCoffee.roastDate ?? Date() },
                        set: { viewModel.newCoffee.roastDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()

                Button("Clear") {
                    viewModel.newCoffee.roastDate = nil
                    viewModel.showRoastDatePicker = false
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
            }
            .onChange(of: viewModel.showRoastDatePicker) { _, isExpanding in
                if isExpanding && viewModel.newCoffee.roastDate == nil {
                    viewModel.newCoffee.roastDate = Date()
                }
            }

            TextField("Origin", text: $viewModel.newCoffee.originLocation)
                .focused($focus, equals: .origin)

            ExpandablePickerRow(
                title: viewModel.newCoffee.process?.title ?? "Process",
                isSelected: viewModel.newCoffee.process != nil,
                isExpanded: $viewModel.showProcessPicker
            ) {
                ItemPickerView(
                    items: [ProcessMethod.washed, .natural, .honey, .wetHulled],
                    selectedItem: viewModel.newCoffee.process
                ) { process in
                    viewModel.newCoffee.process = process
                    viewModel.showProcessPicker = false
                }
            }
        }
    }

    private enum Field {
        case name, roaster, origin

        var next: Field? {
            switch self {
            case .name: return .roaster
            case .roaster: return .origin
            case .origin: return nil
            }
        }

        var previous: Field? {
            switch self {
            case .name: return nil
            case .roaster: return .name
            case .origin: return .roaster
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddCoffeeView()
    }
}
