//
//  OriginView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import BrewLoggerDomain

struct OriginView: View {
    let origin: OriginInfo
    
    var body: some View {
        // TODO: More about the origin
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
        // TODO: Map View Highlight
    }
}

#Preview {
    OriginView(origin: .init(location: "Huila, Colombia", altitude: 1750))
}
