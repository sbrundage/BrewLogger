//
//  ExpandablePickerView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/14/26.
//

import SwiftUI

struct ExpandablePickerRow<Content: View>: View {
    let title: String
    let isSelected: Bool
    
    @Binding var isExpanded: Bool
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(isSelected ? Color(.label) : Color(.placeholderText))
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
        
        if isExpanded { content() }
    }
}

import BrewLoggerDomain

#Preview("Method Picker") {
    @Previewable @State var isExpanded = false
    @Previewable @State var selected: BrewMethod? = nil

    Form {
        Section("Required") {
            ExpandablePickerRow(
                title: selected?.title ?? "Select a method",
                isSelected: selected != nil,
                isExpanded: $isExpanded
            ) {
                ItemPickerView(
                    items: [BrewMethod.pourOver, .espresso],
                    selectedItem: selected
                ) { selected = $0 }
            }
        }
    }
}

#Preview("Coffee Picker") {
    @Previewable @State var isExpanded = false
    @Previewable @State var selected: Coffee? = nil
    @Previewable @State var search = ""

    Form {
        Section("Required") {
            ExpandablePickerRow(
                title: selected?.name ?? "Select a coffee",
                isSelected: selected != nil,
                isExpanded: $isExpanded
            ) {
                CoffeePickerView(
                    coffeeSearch: $search,
                    filteredCoffees: Coffee.previewList,
                    selectedCoffee: selected,
                    addNewCoffee: {},
                    onCoffeeOptionTap: { selected = $0 }
                )
            }
        }
    }
}
