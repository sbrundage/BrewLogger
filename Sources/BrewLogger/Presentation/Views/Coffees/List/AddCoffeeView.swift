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
    @State private var showRoastLevelPicker = false
    @State private var showRoastDatePicker = false
    @State private var showProcessPicker = false
    
    let onSuccessfulSave: ((Coffee) -> ())?

    @FocusState private var focus: Field?
    
    init(onSuccessfulSave: ((Coffee) -> ())? = nil) {
        self.onSuccessfulSave = onSuccessfulSave
    }

    var body: some View {
        Form {
            requiredSection
            optionalSection

            Button {
                do {
                    let savedCoffee = try viewModel.saveCoffee()
                    onSuccessfulSave?(savedCoffee)
                    dismiss()
                }
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

            // Roast Level
            ExpandablePickerRow(
                title: viewModel.newCoffee.roastLevel?.title ?? "Roast Level",
                isSelected: viewModel.newCoffee.roastLevel != nil,
                isExpanded: $showRoastLevelPicker
            ) {
                ItemPickerView(
                    items: RoastLevel.allCases,
                    selectedItem: viewModel.newCoffee.roastLevel
                ) { level in
                    withAnimation(.spring(duration: 0.2)) { showRoastLevelPicker = false }
                    viewModel.newCoffee.roastLevel = level
                }
            }

            // Roast Date
            ExpandablePickerRow(
                title: viewModel.newCoffee.roastDate?.shortFormatted ?? "Roast Date",
                isSelected: viewModel.newCoffee.roastDate != nil,
                isExpanded: $showRoastDatePicker
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
                .tint(.cyan)

                Button {
                    viewModel.newCoffee.roastDate = nil
                    // TODO: This doesn't animate closed
//                    withAnimation(.spring(duration: 0.2)) { showRoastDatePicker = false }
                } label: {
                    Text("Clear")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .listRowSeparator(.hidden)
            }

            TextField("Origin", text: $viewModel.newCoffee.originLocation)
                .focused($focus, equals: .origin)

            TextField("Altitude (masl)", text: $viewModel.newCoffee.originAltitude)
                .keyboardType(.numberPad)
                .focused($focus, equals: .altitude)

            // Roast Process
            ExpandablePickerRow(
                title: viewModel.newCoffee.process?.title ?? "Process",
                isSelected: viewModel.newCoffee.process != nil,
                isExpanded: $showProcessPicker
            ) {
                ItemPickerView(
                    items: ProcessMethod.allCases,
                    selectedItem: viewModel.newCoffee.process
                ) { process in
                    withAnimation(.spring(duration: 0.2)) { showProcessPicker = false }
                    viewModel.newCoffee.process = process
                }
            }

            TextField("Variety", text: $viewModel.newCoffee.variety)
                .focused($focus, equals: .variety)
        }
    }

    private enum Field {
        case name, roaster, origin, altitude, variety

        var next: Field? {
            switch self {
            case .name: return .roaster
            case .roaster: return .origin
            case .origin: return .altitude
            case .altitude: return .variety
            case .variety: return nil
            }
        }

        var previous: Field? {
            switch self {
            case .name: return nil
            case .roaster: return .name
            case .origin: return .roaster
            case .altitude: return .origin
            case .variety: return .altitude
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddCoffeeView()
    }
}
