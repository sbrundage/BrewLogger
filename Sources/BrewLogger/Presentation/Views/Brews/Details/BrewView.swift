//
//  BrewView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/11/26.
//

import SwiftUI
import BrewLoggerDomain

struct BrewView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let brew: Brew
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(brew.coffee.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let rating = brew.rating {
                    Text("\(rating.tens)")
                    
                    Image(systemName: "star.fill")
                }
            } //: HStack
            
            (Text(brew.date.monthDay) +
             Text(" at ") +
             Text(brew.date, style: .time))
                .font(.subheadline)
                .padding(.top, 2)
            
            HStack {
                BrewRatioDetailsView(brew: brew, baseFontWeight: .medium, emphasizeFont: .headline)

                Spacer()
                
                if let brewImage = brew.method.image {
                    brewImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            } //: HStack
            .padding(.top, 12)
        } //: VStack
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(colorScheme == .dark ? BrandColors.forestDark : BrandColors.forestLight)
        )
    }
}

#Preview {
    BrewView(brew: Brew.preview)
}
