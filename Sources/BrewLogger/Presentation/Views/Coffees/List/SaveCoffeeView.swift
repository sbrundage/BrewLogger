//
//  SaveCoffeeView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/1/26.
//

import SwiftUI
import BrewLoggerDomain

struct SaveCoffeeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: SaveCoffeeViewModel
    @State private var showRoastLevelPicker = false
    @State private var showRoastDatePicker = false
    @State private var showProcessPicker = false
    
    let onSuccessfulSave: ((Coffee) -> ())?

    @FocusState private var focus: Field?
    
    init(coffeeToEdit: Coffee? = nil, onSuccessfulSave: ((Coffee) -> ())? = nil) {
        self.viewModel = SaveCoffeeViewModel(coffeeToEdit: coffeeToEdit)
        self.onSuccessfulSave = onSuccessfulSave
    }

    var body: some View {
        Form {
            requiredSection
            optionalSection

            Button {
                Task {
                    do {
                        let savedCoffee = try await viewModel.saveCoffee()
                        onSuccessfulSave?(savedCoffee)
                        dismiss()
                    }
                    catch { /* TODO: Handle error */ }
                }
            } label: {
                Text("Save Coffee")
            }
            .foregroundStyle(viewModel.canSave ? BrandColors.accent : .secondary)
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.canSave)
        }
        .navigationTitle(viewModel.isEditing ? "Edit Coffee" : "New Coffee")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
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

    private var requiredSection: some View {
        Section("Required") {
            TextField("Coffee Name", text: $viewModel.coffee.name)
                .focused($focus, equals: .name)
        }
    }

    private var optionalSection: some View {
        Section("Optional") {
            TextField("Roaster", text: $viewModel.coffee.roaster)
                .focused($focus, equals: .roaster)

            // Roast Level
            ExpandablePickerRow(
                title: viewModel.coffee.roastLevel?.title ?? "Roast Level",
                isSelected: viewModel.coffee.roastLevel != nil,
                isExpanded: $showRoastLevelPicker
            ) {
                ItemPickerView(
                    items: RoastLevel.allCases,
                    selectedItem: viewModel.coffee.roastLevel
                ) { level in
                    withAnimation(.spring(duration: 0.2)) { showRoastLevelPicker = false }
                    viewModel.coffee.roastLevel = level
                }
            }

            // Roast Date
            ExpandablePickerRow(
                title: viewModel.coffee.roastDate?.shortFormatted ?? "Roast Date",
                isSelected: viewModel.coffee.roastDate != nil,
                isExpanded: $showRoastDatePicker
            ) {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.coffee.roastDate ?? Date() },
                        set: { viewModel.coffee.roastDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(BrandColors.accent)

                Button {
                    viewModel.coffee.roastDate = nil
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

            TextField("Origin", text: $viewModel.coffee.originLocation)
                .focused($focus, equals: .origin)

            TextField("Altitude (masl)", text: $viewModel.coffee.originAltitude)
                .keyboardType(.numberPad)
                .focused($focus, equals: .altitude)

            // Roast Process
            ExpandablePickerRow(
                title: viewModel.coffee.process?.title ?? "Process",
                isSelected: viewModel.coffee.process != nil,
                isExpanded: $showProcessPicker
            ) {
                ItemPickerView(
                    items: ProcessMethod.allCases,
                    selectedItem: viewModel.coffee.process
                ) { process in
                    withAnimation(.spring(duration: 0.2)) { showProcessPicker = false }
                    viewModel.coffee.process = process
                }
            }

            TextField("Variety", text: $viewModel.coffee.variety)
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
        SaveCoffeeView()
    }
}
