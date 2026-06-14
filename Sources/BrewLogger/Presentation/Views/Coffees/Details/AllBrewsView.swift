//
//  AllBrewsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/12/26.
//

import SwiftUI
import BrewLoggerDomain

struct AllBrewsView: View {
    @State private var viewModel: ViewModel
    
    let title: String
    
    init(title: String, brews: [Brew]) {
        self.viewModel = ViewModel(brews: brews)
        self.title = title
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.shouldShowMethodFilters {
                methodFilters
                    .padding(.horizontal)
            }
            
            listView
        } //: VStack
        .navigationTitle(title)
    }
    
    private var methodFilters: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(BrewMethod.allMethods) { method in
                    Button {
                        viewModel.updateSelectedMethod(method)
                    } label: {
                        Text(method.title)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(viewModel.isMethodSelected(method) ? BrandColors.accent : .gray)
                            )
                    }

                } //: ForEach
            } //: HStack
        } //: ScrollView
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.displayBrews) { brew in
                BrewRow(brew: brew)
            }
        }
    }
}

#Preview {
    AllBrewsView(title: Coffee.preview.name, brews: Brew.previewList)
}
