//
//  AddBrewView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/12/26.
//

import SwiftUI
import BrewLoggerDomain

struct AddBrewView: View {
    @State private var viewModel = AddBrewViewModel()
    @State private var showCoffeePicker = false
    @State private var showMethodPicker = false
    @State private var coffeeSearch = ""

    var body: some View {
        Form {
            requiredFieldsSection

            optionalFieldsSection
        }
        .navigationTitle("New Brew")
        .overlay {
            if showCoffeePicker {
                SelectionPopup(
                    title: "Select a Coffee",
                    items: Coffee.previewList,
                    label: \.name,
                    selected: $viewModel.newBrew.coffee,
                    isPresented: $showCoffeePicker
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            if showMethodPicker {
                SelectionPopup(
                    title: "Select a Method",
                    items: [BrewMethod.pourOver, .espresso],
                    label: \.title,
                    selected: $viewModel.newBrew.method,
                    isPresented: $showMethodPicker
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(duration: 0.25), value: showCoffeePicker)
        .animation(.spring(duration: 0.25), value: showMethodPicker)
    }
    
    private var requiredFieldsSection: some View {
        Section("Required") {
            Button(viewModel.newBrew.coffee?.name ?? "Select a coffee") {
                showCoffeePicker = true
            }
            .foregroundStyle(viewModel.newBrew.coffee == nil ? .secondary : .primary)

            Button(viewModel.newBrew.method?.title ?? "Select a method") {
                showMethodPicker = true
            }
            .foregroundStyle(viewModel.newBrew.method == nil ? .secondary : .primary)

            TextField("Dose (g)", text: $viewModel.doseInput)
                .keyboardType(.decimalPad)

            TextField("Yield (g)", text: $viewModel.yieldInput)
                .keyboardType(.decimalPad)

            TextField("Brew Time", text: $viewModel.brewTimeInput)
                .keyboardType(.decimalPad)
        }
    }
    
    private var optionalFieldsSection: some View {
        Section("Optional") {
            TextField("Rating (0–5)", text: $viewModel.ratingInput)
                .keyboardType(.decimalPad)

            TextField("Notes", text: Binding(
                get: { viewModel.newBrew.notes ?? "" },
                set: { viewModel.newBrew.notes = $0.isEmpty ? nil : $0 }
            ), axis: .vertical)
                .lineLimit(3...6)
        }
    }
}

struct UpdatedAddBrewView: View {
    @State private var viewModel = AddBrewViewModel()
    @State private var showCoffeePicker = false
    @State private var showMethodPicker = false
    @State private var coffeeSearch: String = ""

    var body: some View {
        Form {
            requiredFieldsSection
            optionalFieldsSection
            
            
            if viewModel.canSave {
                Button {
                    // TODO: Save Brew
                    print("saving brew")
                } label: {
                    Text("Save Brew")
                }
                .foregroundStyle(.cyan)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("New Brew")
        .animation(.spring(duration: 0.2), value: showCoffeePicker)
        .animation(.spring(duration: 0.2), value: showMethodPicker)
    }

    private var requiredFieldsSection: some View {
        Section("Required") {
            // Coffee expandable
            Button {
                showCoffeePicker.toggle()
            } label: {
                HStack {
                    Text(viewModel.newBrew.coffee?.name ?? "Select a coffee")
                        .foregroundStyle(viewModel.newBrew.coffee == nil ? .gray : .white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(showCoffeePicker ? 180 : 0))
                        .foregroundStyle(.gray)
                }
            }

            if showCoffeePicker {
                // Search + add new coffee
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search", text: $coffeeSearch)
                    Spacer()
                    Button {
                        // TODO: present add coffee flow
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.cyan)
                    }
                }
                .listRowBackground(Color(.secondarySystemFill))

                let filtered = coffeeSearch.isEmpty
                    ? Coffee.previewList
                    : Coffee.previewList.filter { $0.name.localizedCaseInsensitiveContains(coffeeSearch) }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered) { coffee in
                            Button {
                                viewModel.newBrew.coffee = coffee
                                showCoffeePicker = false
                                coffeeSearch = ""
                            } label: {
                                HStack {
                                    Text(coffee.name)
                                    Spacer()
                                    if viewModel.newBrew.coffee == coffee {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.trailing, 8) // prevent checkmark hiding behind scroll indicator
                            }
                            .foregroundStyle(.primary)

                            if coffee.id != filtered.last?.id { Divider() }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .listRowBackground(Color(.secondarySystemFill))
            }

            // Method expandable
            Button {
                showMethodPicker.toggle()
            } label: {
                HStack {
                    Text(viewModel.newBrew.method?.title ?? "Select a method")
                        .foregroundStyle(viewModel.newBrew.method == nil ? .gray : .white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(showMethodPicker ? 180 : 0))
                        .foregroundStyle(.gray)
                }
            }

            if showMethodPicker {
                VStack(spacing: 0) {
                    ForEach([BrewMethod.pourOver, .espresso], id: \.self) { method in
                        Button {
                            viewModel.newBrew.method = method
                            showMethodPicker = false
                        } label: {
                            HStack {
                                Text(method.title)
                                Spacer()
                                if viewModel.newBrew.method == method {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.trailing, 8)
                        }
                        .foregroundStyle(.primary)

                        if method != .espresso { Divider() }
                    }
                }
                .listRowBackground(Color(.secondarySystemFill))
            }

            TextField("Dose (g)", text: $viewModel.doseInput)
                .keyboardType(.decimalPad)

            TextField("Yield (g)", text: $viewModel.yieldInput)
                .keyboardType(.decimalPad)

            TextField("Brew Time", text: $viewModel.brewTimeInput)
                .keyboardType(.decimalPad)
        }
    }

    private var optionalFieldsSection: some View {
        Section("Optional") {
            TextField("Rating (0–5)", text: $viewModel.ratingInput)
                .keyboardType(.decimalPad)

            TextField("Notes", text: Binding(
                get: { viewModel.newBrew.notes ?? "" },
                set: { viewModel.newBrew.notes = $0.isEmpty ? nil : $0 }
            ), axis: .vertical)
                .lineLimit(3...6)
        }
    }
}

#Preview {
    UpdatedAddBrewView()
}
