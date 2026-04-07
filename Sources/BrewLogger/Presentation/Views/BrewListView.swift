//
//  SwiftUIView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 2/19/26.
//

import SwiftUI

struct BrewListView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<15) { x in
                    Text("Brew \(x)")
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.cyan)
                        )
                        .frame(maxWidth: .infinity)
                } //: ForEach
            } //: LazyVStack
            .padding(.horizontal)
        } //: ScrollView
    }
}

#Preview {
    BrewListView()
}
