//
//  SelectionPopup.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/12/26.
//

import SwiftUI

struct SelectionPopup<Item: Hashable>: View {
    let title: String
    let items: [Item]
    let label: (Item) -> String
    
    @Binding var selected: Item?
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .allowsHitTesting(isPresented)
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                Text(title)
                    .font(.headline)
                    .padding()

                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(items, id: \.self) { item in
                            Button {
                                selected = item
                                isPresented = false
                            } label: {
                                HStack {
                                    Text(label(item))
                                    Spacer()
                                    if selected == item {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .padding()
                            }
                            .foregroundStyle(.primary)

                            if item != items.last { Divider() }
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
        }
    }
}

//#Preview {
//    SelectionPopup<Coffee>()
//}
