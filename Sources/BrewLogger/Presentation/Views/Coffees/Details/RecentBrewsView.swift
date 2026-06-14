//
//  RecentBrewsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/10/26.
//

import SwiftUI
import BrewLoggerDomain

struct RecentBrewsView: View {
    private let maxBrews = 3
    
    let brews: [Brew]
    let onSeeAllTapped: () -> ()
    
    init(brews: [Brew], onSeeAllTapped: @escaping () -> Void) {
        self.brews = Array(brews.prefix(maxBrews))
        self.onSeeAllTapped = onSeeAllTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Recent Brews")
                    .font(.headline)
                    
                Spacer()
                
                Button {
                    onSeeAllTapped()
                } label: {
                    Text("See All")
                        .foregroundStyle(BrandColors.accent)
                }
            } //: HStack
            .padding(.bottom, 8)
            
            ForEach(brews) { brew in
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(brew.coffee.name)
                        
                        if let brewImage = brew.method.image {
                            brewImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                        
                        Spacer()
                        
                        if let rating = brew.rating {
                            Text("\(rating.tens)")
                            Image(systemName: "star.fill")
                        }
                    } //: HStack
                    
                    BrewRatioDetailsView(
                        brew: brew,
                        baseFontWeight: .medium,
                        emphasizeFont: .headline
                    )
                    
                    if brew.id != brews.last?.id {
                        Divider()
                            .padding(8)
                    }
                } //: VStack
            }
        } //: VStack
    }
}

#Preview {
    RecentBrewsView(brews: [
        .previewList[0],
        .previewList[1]
    ], onSeeAllTapped: {})
}
