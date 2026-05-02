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
            HStack {
                Text(coffee.name)
                    .font(.headline)
                
                Spacer()
                
                if let roaster = coffee.roastInfo?.roaster {
                    Text(roaster)
                        .font(.subheadline)
                }
            } //: HStack
            
            HStack(alignment: .top) {
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
                
                if let roastDate = coffee.roastInfo?.date {
                    Text(roastDate.shortFormatted)
                        .font(.caption)
                }
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
    let coffee = Coffee(name: "Test Coffee", originInfo: nil, roastInfo: nil, process: nil)
    CoffeeView(coffee: coffee)
}
