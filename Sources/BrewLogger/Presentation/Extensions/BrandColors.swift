//
//  BrandColors.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/15/26.
//

import SwiftUI

public enum BrandColors {
    // MARK: - Accent — change this one line to retheme the entire app
    public static let accent: Color = Color(hex: "#4CAF82")  // sage green — earthy, works on dark
    

    // Option A: Slate — blue-gray, pairs naturally with cyan
    static let slateLight = Color(hex: "#DCE4EA")
    static let slateDark  = Color(hex: "#1E2B35")

    // Option B: Espresso — warm dark, very on-brand for coffee
    static let espressoLight = Color(hex: "#F0E9E1")
    static let espressoDark  = Color(hex: "#24180F")

    // Option C: Stone — muted warm gray, safe and neutral
    static let stoneLight = Color(hex: "#EDEAE6")
    static let stoneDark  = Color(hex: "#2B2825")

    // Option D: Forest — earthy green, interesting contrast with cyan
    static let forestLight = Color(hex: "#E5EDE7")
    static let forestDark  = Color(hex: "#1A2B1E")

    // Option E: Charcoal — clean, modern, minimal
    static let charcoalLight = Color(hex: "#EBEBEB")
    static let charcoalDark  = Color(hex: "#252525")
}
