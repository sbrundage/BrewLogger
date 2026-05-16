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
            
            (Text(brew.date, style: .date) +
             Text(" at ") +
             Text(brew.date, style: .time))
                .font(.subheadline)
                .padding(.top, 2)
            
            HStack {
                (Text("\(brew.dose.tens)g").fontWeight(.medium) +
                 Text(" : ").fontWeight(.light) +
                 Text("\(brew.yield.tens)g").fontWeight(.medium) +
                 Text(" in ").fontWeight(.light) +
                 Text("\(brew.brewTime.tens)s").fontWeight(.medium))
                .font(.headline)

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
                .foregroundStyle(colorScheme == .dark ? BrandColors.slateDark : BrandColors.slateLight)
        )
    }
}

#Preview {
    BrewView(brew: Brew.preview)
}
