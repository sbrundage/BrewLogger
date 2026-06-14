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
        VStack(alignment: .leading, spacing: 8) {
            Text("Origin Info")
                .font(.headline)

            HStack {
                Text(origin.location)

                Spacer()

                if let altitude = origin.altitude {
                    Text("\(altitude) masl")
                }
            }

            OriginMapView(location: origin.location)

            if #available(iOS 26.0, *) {
                OriginIntelligenceView(origin: origin)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Foundation Models

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
struct OriginIntelligenceView: View {
    let model = SystemLanguageModel.default
    let origin: OriginInfo

    var body: some View {
        switch model.availability {
        case .available:
            OriginLearnMoreView(origin: origin)
        case .unavailable(.appleIntelligenceNotEnabled):
            Text("Enable Apple Intelligence in Settings to learn more about this origin.")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .unavailable(.modelNotReady):
            Text("Apple Intelligence is downloading. Check back soon.")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .unavailable:
            EmptyView()
        @unknown default:
            EmptyView()
        }
        // TODO: Map View Highlight
    }
}

@available(iOS 26.0, *)
struct OriginLearnMoreView: View {
    @State private var generator: OriginDetailsGenerator?

    let origin: OriginInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let generatedDetails = generator?.originDetails {
                OriginGeneratedTextView(originDetails: generatedDetails)
            }

            Button {
                Task { await generator?.generateOriginInfo() }
            } label: {
                HStack {
                    Text("Learn More")
                        .fontWeight(.medium)
                    Image(systemName: "sparkles")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.gray.opacity(0.2))
            )
            .tint(BrandColors.accent)
        }
        .task {
            self.generator = OriginDetailsGenerator(origin: origin)
        }
    }
}

@available(iOS 26.0, *)
struct OriginGeneratedTextView: View {
    let originDetails: OriginDetails.PartiallyGenerated

    var body: some View {
        if let description = originDetails.description {
            Text(description)
        }
    }
}

@available(iOS 26.0, *)
@MainActor @Observable
final class OriginDetailsGenerator {
    private let session: LanguageModelSession

    let origin: OriginInfo
    private(set) var originDetails: OriginDetails.PartiallyGenerated?
    var error: Error?

    init(origin: OriginInfo) {
        self.origin = origin

        // TODO: Add FindPointsOfInterestTool
        let instructions = Instructions {
            "Your job is to explain more about the region where this coffee is from: \(origin.location)"
            "Keep response very specific to someone who wants to learn more about the specific terroir, climate, environment, and coffee in the region."
        }

        self.session = LanguageModelSession(instructions: instructions)
    }

    func generateOriginInfo() async {
        do {
            let prompt = Prompt {
                "Generate a description about the region \(origin.location) when it comes to coffee."
                "Here is an example of the desired format, but don't copy its content:"
                OriginDetails.example
            }
            let stream = session.streamResponse(to: prompt, generating: OriginDetails.self, options: .init(sampling: .greedy))
            for try await partialResponse in stream {
                self.originDetails = partialResponse.content
            }
        } catch {
            self.error = error
        }
    }

    func prewarmModel() {
        // TODO: Pre-warm the model before the user navigates to this view
    }
}

@available(iOS 26.0, *)
@Generable
struct OriginDetails: Equatable {
    @Guide(description: "More information about the origin and it's coffee region no longer than 4 sentences.")
    let description: String
}

@available(iOS 26.0, *)
extension OriginDetails {
    static let example = OriginDetails(description: "A description of the origin.")
}

#endif

// MARK: - Previews

#Preview("With Foundation Models") {
    if #available(iOS 26.0, *) {
        OriginView(origin: .init(location: "Huila, Colombia", altitude: 1750))
    }
}

#Preview("Origin Only") {
    OriginView(origin: .init(location: "Huila, Colombia", altitude: 1750))
}
