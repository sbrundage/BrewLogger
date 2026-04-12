//
//  CoffeeListView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import BrewLoggerDomain
import CoreLogger

struct CoffeeListView: View {
    @State private var viewModel = CoffeeViewModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.coffees) { coffee in
                    CoffeeView(coffee: coffee)
                        .frame(maxWidth: .infinity)
                } //: ForEach
            } //: LazyVStack
            .padding(.horizontal)
        } //: ScrollView
    }
}

#Preview {
    CoffeeListView()
        .environment(\.managedObjectContext, PersistenceController.stubbedPreviewCoffees.container.viewContext)
}
