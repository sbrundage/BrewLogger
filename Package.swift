// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BrewLogger",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BrewLoggerApplication",
            targets: ["BrewLoggerApplication"]
        ),
        .library(
            name: "BrewLoggerPresentation",
            targets: ["BrewLoggerPresentation"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:sbrundage/CoreLogger.git", branch: "develop")
    ],
    targets: [
        .target(
            name: "BrewLoggerApplication",
            dependencies: [
                "BrewLoggerDomain",
                "BrewLoggerData",
                "CoreLogger"
            ],
            path: "Sources/BrewLogger/Application",
        ),
        .target(
            name: "BrewLoggerDomain",
            dependencies: [],
            path: "Sources/BrewLogger/Domain",
        ),
        .target(
            name: "BrewLoggerData",
            dependencies: [
                "BrewLoggerDomain",
                "CoreLogger"
            ],
            path: "Sources/BrewLogger/Data",
        ),
        .target(
            name: "BrewLoggerPresentation",
            dependencies: [
                "BrewLoggerApplication",
                "BrewLoggerDomain",
                "CoreLogger"
            ],
            path: "Sources/BrewLogger/Presentation"
        ),
        .testTarget(
            name: "BrewLoggerTests",
            dependencies: ["BrewLoggerPresentation", "BrewLoggerData", "BrewLoggerDomain"],
            path: "Tests/BrewLoggerTests"
        )
    ]
)
