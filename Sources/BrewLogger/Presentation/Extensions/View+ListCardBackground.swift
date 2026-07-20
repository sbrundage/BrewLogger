//
//  View+ListCardBackground.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/19/26.
//

import SwiftUI

extension View {
    /// Rounded card behind a list row with background color.
    func listCardBackground() -> some View {
        modifier(ListCardBackground())
    }
}

private struct ListCardBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(colorScheme == .dark ? BrandColors.forestDark : BrandColors.forestLight)
            )
    }
}
