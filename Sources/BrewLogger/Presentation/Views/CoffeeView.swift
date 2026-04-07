//
//  CoffeeView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import BrewLoggerDomain

struct CoffeeView: View {
    let coffee: Coffee
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(coffee.name)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    if let origin = coffee.originInfo {
                        Text(origin.location)
                            .font(.subheadline)
                    }
                    
                    if let altitude = coffee.originInfo?.altitude {
                        Text("\(altitude) masl")
                            .font(.caption)
                    }
                } //: VStack
                
                Spacer()
                
                VStack(alignment: .leading) {
                    if let roaster = coffee.roastInfo?.roaster {
                        Text(roaster)
                            .font(.subheadline)
                    }
                    
                    if let roastDate = coffee.roastInfo?.date {
                        Text(roastDate.shortFormatted)
                            .font(.caption)
                    }
                } //: VStack
            } //: HStack
        } //: VStack
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color(hex: "#966E4A"))
        )
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CoffeeView(coffee: .preview)
}
