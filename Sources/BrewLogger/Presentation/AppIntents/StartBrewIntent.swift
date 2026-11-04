//
//  StartBrewIntent.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/1/26.
//

import AppIntents

public struct StartBrewIntent: AppIntent {
    public static let title: LocalizedStringResource = "Start a Brew"
    public static let description = IntentDescription("Opens Pocket Logger to log a new brew.")
    public static var supportedModes: IntentModes { .foreground }

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        AppNavigationCoordinator.shared.request(.addBrew)
        return .result()
    }
}
