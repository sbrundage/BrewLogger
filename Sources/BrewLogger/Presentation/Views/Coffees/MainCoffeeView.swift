//
//  MainCoffeeView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/2/26.
//

import SwiftUI

public struct MainCoffeeView: View {
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            CoffeeListView()
        }
    }
}

#Preview {
    MainCoffeeView()
}
