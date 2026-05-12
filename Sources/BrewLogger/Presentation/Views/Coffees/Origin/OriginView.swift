//
//  OriginView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import BrewLoggerDomain

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
struct OriginView: View {
    let model = SystemLanguageModel.default
    let origin: OriginInfo
    
    var body: some View {
        switch model.availability {
        case .available:
            OriginDetailsView(origin: origin)
        case .unavailable:
            Text("Trip Planner is unavailable because Apple Intelligence has not been turned on.")
        @unknown default:
            Text("Trip Planner is unavailable. Try again later.")
        }
        
        // TODO: Map View Highlight
    }
}

@available(iOS 26.0, *)
struct OriginDetailsView: View {
    @State private var originDetailsGenerator: OriginDetailsGenerator?
    
    let origin: OriginInfo
    
    var body: some View {
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
            
            if let generatedDetails = originDetailsGenerator?.originDetails {
                OriginDetailsGeneratedView(originDetails: generatedDetails)
            }
            
            Button {
                Task {
                    await originDetailsGenerator?.generateOriginInfo()
                }
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
        .task {
            self.originDetailsGenerator = OriginDetailsGenerator(origin: origin)
        }
    }
}

@available(iOS 26.0, *)
struct OriginDetailsGeneratedView: View {
    let originDetails: OriginDetails.PartiallyGenerated
    
    var body: some View {
        if let originDescription = originDetails.description {
            Text(originDescription)
        }
    }
}

@available(iOS 26.0, *)
@MainActor @Observable
final class OriginDetailsGenerator {
    private let session: LanguageModelSession
    
    let origin: OriginInfo

    // MARK: - [CODE-ALONG] Chapter 2.3.1: Update to Generable
    private(set) var originDetails: OriginDetails.PartiallyGenerated?

    var error: Error?

    init(origin: OriginInfo) {
        self.origin = origin
        
        // TODO: - Create tool
//        let pointOfInterestTool = FindPointsOfInterestTool(landmark: landmark)
        let instructions = Instructions {
            "Your job is to explain more about the region where this coffee is from: \(origin.location)"
            "Keep response very specific to someone who wants to learn more about the specific terroir, climate, environment, and coffee in the region."
        }

        // TODO: - Update the LanguageModelSession with the tool
        
        self.session = LanguageModelSession(instructions: instructions)
    }
    
    func generateOriginInfo() async {
        do {
            // let prompt = "Generate a \(dayCount)-day itinerary to \(landmark.name)."
            // MARK: - [CODE-ALONG] Chapter 3.3: Update to use one-shot prompting
            let prompt = Prompt {
                "Generate a description about the region \(origin.location) when it comes to coffee."
                "Here is an example of the desired format, but don't copy its content:"
                OriginDetails.example
            }
            
            // MARK: - [CODE-ALONG] Chapter 5.3.3: Update `session.streamResponse` to include greedy sampling
            let stream = session.streamResponse(to: prompt, generating: OriginDetails.self, options: .init(sampling: .greedy))
            
            for try await partialResponse in stream {
                self.originDetails = partialResponse.content
            }
        } catch {
            self.error = error
        }

        // MARK: - [CODE-ALONG] Chapter 6.2.1: Update to exclude schema from prompt
         
    }

    func prewarmModel() {
        // MARK: - [CODE-ALONG] Chapter 6.1.1: Add a function to pre-warm the model
    }
}

@available(iOS 26.0, *)
@Generable
struct OriginDetails: Equatable {
    @Guide(description: "More information about the origin and it's coffee region no longer than 4 sentences.")
    let description: String
//    
//    @Guide(description: "A list of day-by-day plans.")
//    @Guide(.count(3))
//    let days: [DayPlan]
}

@available(iOS 26.0, *)
extension OriginDetails {
    static let example = OriginDetails(description: "A description of the origin.")
}

@available(iOS 26.0, *)
#Preview {
    OriginView(origin: .init(location: "Huila, Colombia", altitude: 1750))
}
#endif
