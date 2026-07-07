//
//  SeeSomeView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/29/26.
//

import SwiftUI
import BrewLoggerDomain

struct SeeSomeView<Item: Identifiable & Equatable, RowView: View>: View {
    private let horizontalPadding: CGFloat = 14
    
    let items: [Item]
    let itemsToShow: Int // is this necessary or just pass in the items to show without this view having to have logic around prefixing the array
    let title: String
    let onSeeAllTapped: () -> ()
    
    @ViewBuilder let itemView: (Item) -> RowView
    
    init(
        items: [Item],
        itemsToShow: Int = 3,
        title: String,
        onSeeAllTapped: @escaping () -> Void,
        @ViewBuilder itemView: @escaping (Item) -> RowView
    ) {
        self.items = Array(items.prefix(itemsToShow))
        self.itemsToShow = itemsToShow
        self.title = title
        self.onSeeAllTapped = onSeeAllTapped
        self.itemView = itemView
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    
                Spacer()
                
                Button { onSeeAllTapped() } label: {
                    Text("See All")
                        .foregroundStyle(BrandColors.accent)
                }
            } //: HStack
            .padding(.bottom, 8)
            .padding(.horizontal, horizontalPadding)
            
            VStack(spacing: 0) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 0) {
                        itemView(item)
                        
                        if item.id != items.last?.id {
                            Divider().padding(.vertical, 12)
                        }
                    } //: VStack
                }
            } //: VStack
            .padding(horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.gray.opacity(0.2))
            )
        } //: VStack
    }
}

#Preview {
    SeeSomeView(
        items: Brew.previewList,
        title: "Recent Brews", onSeeAllTapped: { }
    ) { brew in
        BrewRow(brew: brew)
    }
}
