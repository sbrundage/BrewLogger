//
//  BrewDetailView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/13/26.
//

import SwiftUI
import BrewLoggerDomain

struct BrewDetailView: View {
    let brew: Brew
    
    var body: some View {
        VStack {
            HStack {
                dateView
                    .font(.headline)
                    .padding(.top, 2)
                
                Spacer()
                
                if let rating = brew.rating {
                    Text("\(rating.tens)")
                    
                    Image(systemName: "star.fill")
                }
            } //: HStack
            
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
        } //: VStack
    }
    
    var dateView: some View {
        (Text(brew.date.monthDay) +
         Text(" - ") +
         Text(brew.date, style: .time))
    }
}

#Preview {
    BrewDetailView(brew: .preview)
}
