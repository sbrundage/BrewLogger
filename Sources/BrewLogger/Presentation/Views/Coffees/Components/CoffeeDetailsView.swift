//
//  CoffeeDetailsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/3/26.
//

import SwiftUI
import BrewLoggerDomain

@MainActor @Observable
final class CoffeeDetailsViewModel {
    
}

struct CoffeeDetailsView: View {
    let coffee: Coffee
    
    var body: some View {
        VStack(alignment: .leading) {
            brewInfoView
                .padding(.bottom)
            
            if let roastInfo = coffee.roastInfo {
                roastInfoView(roast: roastInfo)
                    .padding(.bottom)
            }
            
            if let originInfo = coffee.originInfo {
                originInfoView(origin: originInfo)
            }
            
            Spacer()
        } //: VStack
        .padding(.horizontal)
        .navigationTitle(coffee.name)
    }
    
    // MARK: Brew Info
    
    private var brewInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
//            Text("Number of Brews: 20")
            
            Text("Highest Rated Brew")
                .font(.headline)
            
            HStack {
                    VStack {
                        Text("Grind Size")
                            .fontWeight(.light)
                        Text("0.5")
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Time")
                            .fontWeight(.light)
                        Text("30s")
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Yield")
                            .fontWeight(.light)
                        Text("34g")
                    } //: VStack
                    .frame(maxWidth: .infinity)
            } //: HStack
        } //: VStack
    }
    
    // MARK: Roast Info
    
    private func roastInfoView(roast: RoastInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Roast Info")
                .font(.headline)
            
            HStack {
                if let roastDate = roast.date {
                    VStack {
                        Text("Roast Date")
                            .fontWeight(.light)
                        Text("\(roastDate.shortFormatted)")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                if let roaster = roast.roaster {
                    VStack {
                        Text("Roaster")
                            .fontWeight(.light)
                        Text("\(roaster)")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                if let roastLevel = roast.roastLevel {
                    VStack {
                        Text("Roast Level")
                            .fontWeight(.light)
                        Text("\(roastLevel.title)")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                }
            } //: HStack
        } //: VStack
        .frame(maxWidth: .infinity)
    }
    
    // MARK: Origin Info
    
    private func originInfoView(origin: OriginInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Origin Info")
                .font(.headline)
            
            HStack {
                Text("\(origin.location)")
                
                Spacer()
                
                if let altitude = origin.altitude {
                    Text("\(altitude) masl")
                }
            } //: HStack
            .padding(.bottom)
            
            Button {
                // TODO:
            } label: {
                HStack {
                    Text("Learn More")
                        .fontWeight(.medium)
                    Image(systemName: "sparkles")
                } //: HStack
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.secondary)
            )
            .tint(.cyan)
        } //: VStack
    }
}

#Preview {
    CoffeeDetailsView(coffee: Coffee.preview)
}
