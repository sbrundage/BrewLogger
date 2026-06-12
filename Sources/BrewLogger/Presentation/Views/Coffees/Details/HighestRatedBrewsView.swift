//
//  HighestRatedBrewsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/10/26.
//

import SwiftUI
import BrewLoggerDomain

struct HighestRatedBrewsView: View {
    let brews: [Brew]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Highest Rated Brew")
                .font(.headline)
            
            ForEach(brews) { brew in
                VStack(alignment: .leading) {
                    Text(brew.method.title)
                        .underline()
                    
                    HStack {
                        VStack {
                            Text("Grind Size")
                                .fontWeight(.light)
                            Text(brew.grindSize.tens)
                                .fontWeight(.medium)
                        } //: VStack
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(width: 0.5, height: 30)
                            .overlay(.secondary)
                        
                        VStack {
                            Text("Time")
                                .fontWeight(.light)
                            Text("\(brew.brewTime.tens)s")
                                .fontWeight(.medium)
                        } //: VStack
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(width: 0.5, height: 30)
                            .overlay(.secondary)
                        
                        VStack {
                            Text("Yield")
                                .fontWeight(.light)
                            Text("\(brew.yield.tens)g")
                                .fontWeight(.medium)
                        } //: VStack
                        .frame(maxWidth: .infinity)
                    } //: HStack
                } //: VStack
            } //: ForEach
            
        } //: VStack
    }
    
    private func highestRatedBrewView(_ brew: Brew) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Highest Rated Brew")
                .font(.headline)
            
            HStack {
                    VStack {
                        Text("Grind Size")
                            .fontWeight(.light)
                        Text(brew.grindSize.tens)
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Time")
                            .fontWeight(.light)
                        Text("\(brew.brewTime.tens)s")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Yield")
                            .fontWeight(.light)
                        Text("\(brew.yield.tens)g")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
            } //: HStack
        } //: VStack
    }
}

#Preview {
    HighestRatedBrewsView(brews: Brew.previewList)
}
