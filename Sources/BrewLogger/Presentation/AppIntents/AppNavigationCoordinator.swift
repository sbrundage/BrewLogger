//
//  AppNavigationCoordinator.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/1/26.
//

import Foundation

public enum AppDestination: Equatable, Sendable {
    case addBrew
}

// Shared bridge so foregrounding App Intents can drive in-app navigation.
@MainActor
@Observable
public final class AppNavigationCoordinator {
    public static let shared = AppNavigationCoordinator()

    public var pendingDestination: AppDestination?

    private init() {}

    public func request(_ destination: AppDestination) {
        pendingDestination = destination
    }
}
