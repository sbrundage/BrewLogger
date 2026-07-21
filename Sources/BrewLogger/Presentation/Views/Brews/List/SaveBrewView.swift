//
//  SaveBrewView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/12/26.
//

import SwiftUI
import BrewLoggerApplication
import BrewLoggerDomain

struct SaveBrewView: View {
    @Environment(BleScaleConnectionManager.self) var connectionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: SaveBrewViewModel
    
    // Navigation
    @State private var showCoffeePicker = false
    @State private var showMethodPicker = false
    @State private var showAddCoffeeView = false

    @FocusState private var focus: Field?
    
    private let onSuccessfulSave: (() -> ())?
    
    private var timeFieldPlaceholder: String {
        connectionManager.isConnected ? "Brew time will be tracked automatically" : "Brew Time"
    }
    
    private var yieldFieldPlaceholder: String {
        connectionManager.isConnected ? "Yield will be tracked automatically" : "Yield (g)"
    }
    
    init(brewToEdit: Brew? = nil, onSuccessfulSave: (() -> ())? = nil) {
        self.viewModel = SaveBrewViewModel(brewToEdit: brewToEdit)
        self.onSuccessfulSave = onSuccessfulSave
    }

    var body: some View {
        Form {
            requiredFieldsSection
            
            if connectionManager.isConnected {
                Section("Scale Reading") {
                    BleLiveScaleView(
                        yield: $viewModel.brew.yield,
                        brewTime: $viewModel.brew.brewTime
                    )
                }
            }

            optionalFieldsSection
            
            Button {
                do {
                    try viewModel.saveBrew()
                    onSuccessfulSave?()
                    dismiss()
                } catch {
                    /* TODO: Handle error */
                }
            } label: {
                Text("Save Brew")
            }
            .foregroundStyle(viewModel.canSave ? BrandColors.accent : .secondary)
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.canSave)
        }
        .navigationTitle(viewModel.isEditing ? "Edit Brew" : "New Brew")
        .onAppear { viewModel.fetchAllCoffees() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button { focus = focus?.previous } label: { Image(systemName: "chevron.up") }
                    .disabled(focus?.previous == nil)

                Button { focus = focus?.next } label: { Image(systemName: "chevron.down") }
                    .disabled(focus?.next == nil)

                Spacer()

                Button("Done") { focus = nil }
            }
        }
        .navigationDestination(isPresented: $showAddCoffeeView) {
            SaveCoffeeView { newCoffee in
                viewModel.brew.coffee = newCoffee
            }
        }
    }

    private var requiredFieldsSection: some View {
        Section("Required") {
            // Select a Coffee
            ExpandablePickerRow(
                title: viewModel.brew.coffee?.name ?? "Select a coffee",
                isSelected: viewModel.brew.coffee != nil,
                isExpanded: $showCoffeePicker
            ) {
                CoffeePickerView(
                    coffeeSearch: $viewModel.coffeeSearch,
                    filteredCoffees: viewModel.filteredCoffees,
                    selectedCoffee: viewModel.brew.coffee,
                    addNewCoffee: { showAddCoffeeView = true },
                    onCoffeeOptionTap: { coffee in
                        withAnimation(.spring(duration: 0.2)) {
                            viewModel.brew.coffee = coffee
                            viewModel.autofillFromLastBrew()
                            viewModel.coffeeSearch = ""
                            showCoffeePicker = false
                        }
                    }
                )
            }

            // Select Brew Method
            ExpandablePickerRow(
                title: viewModel.brew.method?.title ?? "Select a method",
                isSelected: viewModel.brew.method != nil,
                isExpanded: $showMethodPicker
            ) {
                ItemPickerView(
                    items: BrewMethod.allMethods,
                    selectedItem: viewModel.brew.method
                ) { method in
                    withAnimation(.spring(duration: 0.2)) {
                        viewModel.brew.method = method
                        viewModel.autofillFromLastBrew()
                        showMethodPicker = false
                    }
                }
            }
            
            // Grind Size
            TextField("Grind Size", text: $viewModel.brew.grindSize)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .grindSize)
                .modifier(AutofillHighlight(active: viewModel.justAutofilled))

            // Dose
            TextField("Dose (g)", text: $viewModel.brew.dose)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .dose)
                .modifier(AutofillHighlight(active: viewModel.justAutofilled))
            
            // Brew Time
            BrewTimerTextField(
                placeholder: timeFieldPlaceholder,
                focus: $focus,
                focusField: .brewTime,
                brewTime: $viewModel.brew.brewTime,
                stoppedAt: $viewModel.brew.date
            )

            // Yield
            TextField(yieldFieldPlaceholder, text: $viewModel.brew.yield)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .yield)
        }
    }

    private var optionalFieldsSection: some View {
        Section("Optional") {
            // Brew Temp
            TextField("Brew Temp", text: $viewModel.brew.brewTemp)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .brewTemp)
            
            // Rating
            TextField("Rating (0–5)", text: $viewModel.brew.rating)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused($focus, equals: .rating)

            // Notes
            TextField("Notes", text: $viewModel.brew.notes, axis: .vertical)
                .lineLimit(3...6)
                .focused($focus, equals: .notes)
        }
    }

    enum Field {
        case grindSize, dose, brewTime, yield, brewTemp, rating, notes
        
        var next: Field? {
            switch self {
            case .grindSize: return .dose
            case .dose: return .brewTime
            case .brewTime: return .yield
            case .yield: return .brewTemp
            case .brewTemp: return .rating
            case .rating: return .notes
            case .notes: return nil
            }
        }
        
        var previous: Field? {
            switch self {
            case .grindSize: return nil
            case .dose: return .grindSize
            case .brewTime: return .dose
            case .yield: return .brewTime
            case .brewTemp: return .yield
            case .rating: return .brewTemp
            case .notes: return .rating
            }
        }
    }
}

#Preview {
    NavigationStack {
        SaveBrewView(onSuccessfulSave: {})
            .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
    }
}
