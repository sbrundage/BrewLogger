//
//  CoffeePickerView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/13/26.
//

import SwiftUI
import BrewLoggerDomain

struct CoffeePickerView: View {
    @Binding var coffeeSearch: String
    
    let filteredCoffees: [Coffee]
    let selectedCoffee: Coffee?
    let addNewCoffee: () -> Void
    let onCoffeeOptionTap: (Coffee) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search", text: $coffeeSearch)
            
            Spacer()
            
            Button {
                addNewCoffee()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(BrandColors.accent)
            }
        }
        .listRowBackground(Color(.secondarySystemFill))
        
        ItemPickerView(
            items: filteredCoffees,
            selectedItem: selectedCoffee,
            onItemTap: onCoffeeOptionTap
        )
        .frame(maxHeight: 200)
        .listRowBackground(Color(.secondarySystemFill))
    }
}


#Preview {
    CoffeePickerView(
        coffeeSearch: .constant(""),
        filteredCoffees: Coffee.previewList,
        selectedCoffee: nil,
        addNewCoffee: {},
        onCoffeeOptionTap: { _ in })
}
