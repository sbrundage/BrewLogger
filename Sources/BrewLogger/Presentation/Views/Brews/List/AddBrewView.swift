//
//  AddBrewView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/12/26.
//

import SwiftUI
import BrewLoggerApplication
import BrewLoggerDomain

struct AddBrewView: View {
    @Environment(BleScaleConnectionManager.self) var connectionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = AddBrewViewModel()
    
    // Navigation
    @State private var showCoffeePicker = false
    @State private var showMethodPicker = false
    @State private var showAddCoffeeView = false

    @FocusState private var focus: Field?
    
    private var timeFieldPlaceholder: String {
        connectionManager.isConnected ? "Brew time will be tracked automatically" : "Brew Time"
    }
    
    private var yieldFieldPlaceholder: String {
        connectionManager.isConnected ? "Yield will be tracked automatically" : "Yield (g)"
    }

    var body: some View {
        Form {
            requiredFieldsSection
            
            if connectionManager.isConnected {
                Section("Scale Reading") {
                    BleLiveScaleView(
                        yield: $viewModel.newBrew.yield,
                        brewTime: $viewModel.newBrew.brewTime
                    )
                }
            }

            optionalFieldsSection
            
            Button {
                do {
                    try viewModel.saveBrew()
                    dismiss()
                } catch {
                    /* TODO: Handle error */
                }
            } label: {
                Text("Save Brew")
            }
            .foregroundStyle(viewModel.canSave ? .cyan : .secondary)
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.canSave)
        }
        .navigationTitle("New Brew")
        .onAppear { viewModel.fetchAllCoffees() }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Button { focus = focus?.previous } label: { Image(systemName: "chevron.up") }
                        .disabled(focus?.previous == nil)

                    Button { focus = focus?.next } label: { Image(systemName: "chevron.down") }
                        .disabled(focus?.next == nil)

                    Spacer()

                    Button("Done") { focus = nil }
                }
            }
        }
        .navigationDestination(isPresented: $showAddCoffeeView) {
            AddCoffeeView { newCoffee in
                viewModel.newBrew.coffee = newCoffee
            }
        }
    }

    private var requiredFieldsSection: some View {
        Section("Required") {
            // Select a Coffee
            ExpandablePickerRow(
                title: viewModel.newBrew.coffee?.name ?? "Select a coffee",
                isSelected: viewModel.newBrew.coffee != nil,
                isExpanded: $showCoffeePicker
            ) {
                CoffeePickerView(
                    coffeeSearch: $viewModel.coffeeSearch,
                    filteredCoffees: viewModel.filteredCoffees,
                    selectedCoffee: viewModel.newBrew.coffee,
                    addNewCoffee: { showAddCoffeeView = true },
                    onCoffeeOptionTap: { coffee in
                        withAnimation(.spring(duration: 0.2)) { showCoffeePicker = false }
                        viewModel.newBrew.coffee = coffee
                        viewModel.coffeeSearch = ""
                    }
                )
            }

            // Select Brew Method
            ExpandablePickerRow(
                title: viewModel.newBrew.method?.title ?? "Select a method",
                isSelected: viewModel.newBrew.method != nil,
                isExpanded: $showMethodPicker
            ) {
                let displayMethods: [BrewMethod] = [.espresso, .pourOver]
                ItemPickerView(
                    items: displayMethods,
                    selectedItem: viewModel.newBrew.method
                ) { method in
                    withAnimation(.spring(duration: 0.2)) { showMethodPicker = false }
                    viewModel.newBrew.method = method
                }
            }
            
            // Dose
            TextField("Dose (g)", text: $viewModel.newBrew.dose)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .dose)

            // Yield
            TextField(yieldFieldPlaceholder, text: $viewModel.newBrew.yield)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .yield)

            // Time
            TextField(timeFieldPlaceholder, text: $viewModel.newBrew.brewTime)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .brewTime)
        }
    }

    private var optionalFieldsSection: some View {
        Section("Optional") {
            // Rating
            TextField("Rating (0–5)", text: $viewModel.newBrew.rating)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .rating)

            // Notes
            TextField("Notes", text: $viewModel.newBrew.notes, axis: .vertical)
                .lineLimit(3...6)
                .focused($focus, equals: .notes)
        }
    }

    private enum Field {
        case dose, yield, brewTime, rating, notes
        
        var next: Field? {
            switch self {
            case .dose: return .yield
            case .yield: return .brewTime
            case .brewTime: return .rating
            case .rating: return .notes
            case .notes: return nil
            }
        }
        
        var previous: Field? {
            switch self {
            case .dose: return nil
            case .yield: return .dose
            case .brewTime: return .yield
            case .rating: return .brewTime
            case .notes: return .rating
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddBrewView()
            .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
    }
}
