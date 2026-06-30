//
//  NewBrewView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/29/26.
//

import SwiftUI
import BrewLoggerDomain

struct NewBrewView: View {
    let brew: Brew
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(brew.coffee.name)
                    .font(.system(size: 18))
                
                if let brewImage = brew.method.image {
                    brewImage
                        .font(.system(size: 18))
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
        } //: VStack
    }
}

struct NewBrewView2: View {
    let brew: Brew
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                if let brewImage = brew.method.image {
                    brewImage
                        .font(.system(size: 18))
                }
            } //: VStack
            
            VStack(alignment: .leading) {
                HStack {
                    Text(brew.coffee.name)
                        .font(.system(size: 18))
                    
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
            } //: VStack
        } //: HStack
    }
}

struct NewBrewView3: View {
    let brew: Brew
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let brewImage = brew.method.image {
                    brewImage
                        .font(.system(size: 18))
                }
                
                Text(brew.coffee.name)
                    .font(.system(size: 18))
                
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
        } //: VStack
    }
}

#Preview {
    NewBrewView(brew: .preview)
    NewBrewView2(brew: .preview)
    NewBrewView3(brew: .preview)
}
