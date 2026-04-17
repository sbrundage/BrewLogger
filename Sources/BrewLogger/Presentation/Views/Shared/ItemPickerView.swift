//
//  ItemPickerView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/14/26.
//

import SwiftUI
import BrewLoggerDomain

struct ItemPickerView<Item: Listable>: View {
    let items: [Item]
    let selectedItem: Item?
    let onItemTap: (Item) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        onItemTap(item)
                    } label: {
                        HStack {
                            Text(item.title)
                            Spacer()
                            if selectedItem == item {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.trailing, 8) // prevent checkmark hiding behind scroll indicator
                    }
                    .foregroundStyle(.primary)

                    if item.id != items.last?.id { Divider() }
                }
            }
        }
        .listRowBackground(Color(.secondarySystemFill))
    }
}

#Preview {
    let brewMethods: [BrewMethod] = [.espresso, .pourOver]
    ItemPickerView(items: brewMethods, selectedItem: nil, onItemTap: { _ in })
}
