// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "macro-codable-kit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "MacroCodableKit",
            targets: ["MacroCodableKit"]
        ),
    ],
    dependencies: [
        // Read Swift code
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0"
        ),

        // Format Swift code
        .package(
            url: "https://github.com/apple/swift-format.git",
            from: "509.0.0"
        ),

        // Tools for macro development
        .package(
            url: "https://github.com/stackotter/swift-macro-toolkit",
            branch: "main"
        ),

        // Tools for macro development
        .package(
            url: "https://github.com/pointfreeco/swift-macro-testing",
            branch: "main"
        ),
    ],
    targets: [
        // Macro declaration
        .target(
            name: "MacroCodableKit",
            dependencies: ["Macro"]
        ),

        // Macros
        .macro(
            name: "Macro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
                .product(name: "SwiftFormat", package: "swift-format"),
            ]
        ),

        // Tests
        .testTarget(
            name: "MacroCodableKitTests",
            dependencies: [
                "Macro",
                "MacroCodableKit",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
