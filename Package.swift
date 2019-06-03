// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Calcifer",
    dependencies: [
        // MARK: - Dependencies
        .package(
            url: "https://github.com/apple/swift-package-manager.git",
            .exact("0.3.0")
        ),

//        .package(
//            url: "https://github.com/tuist/xcodeproj.git",
//            .upToNextMajor(from: "6.4.0")
//        ),
        .package(
            path: "/Users/vvsmal/Rep/xcodeproj"
        ),
        .package(
            url: "https://github.com/httpswift/swifter.git",
            .exact("1.4.6")
        ),
        .package(
            url: "https://github.com/weichsel/ZIPFoundation/",
            .exact("0.9.8")
        ),
        .package(
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",
            .exact("1.6.2")
        ),
        .package(
            url: "https://github.com/daltoniam/Starscream.git",
            .exact("3.1.0")
        ),
        .package(
            url: "https://github.com/avito-tech/GraphiteClient.git",
            .exact("0.1.0")
        ),
    ],
    targets: [
        // MARK: Calcifer
        .target(
            name: "Calcifer",
            dependencies: [
                "Toolkit",
                "ArgumentsParser",
                "CommandRunner",
                "XcodeProjectBuilder",
                "XcodeProjectChecksumCalculator",
                "XcodeProjectPatcher",
                "DSYMSymbolizer",
                "XcodeBuildEnvironmentParametersParser",
                "RemoteCachePreparer",
                "BuildStepIntegrator",
                "Daemon"
            ]
        ),
        // MARK: CommandRunner
        .target(
            name: "CommandRunner",
            dependencies: [
                "Toolkit",
                "ArgumentsParser",
            ]
        ),
        // MARK: ArgumentsParser
        .target(
            name: "ArgumentsParser",
            dependencies: [
                "Toolkit"
            ]
        ),
        // MARK: StatisticLogger
        .target(
            name: "StatisticLogger",
            dependencies: [
                "XcodeBuildEnvironmentParametersParser",
                "GraphiteClient",
                "Toolkit"
            ]
        ),
        // MARK: RemoteCachePreparer
        .target(
            name: "RemoteCachePreparer",
            dependencies: [
                "XcodeBuildEnvironmentParametersParser",
                "XcodeProjectChecksumCalculator",
                "BuildProductCacheStorage",
                "BuildArtifacts",
                "XcodeProjectPatcher",
                "XcodeProjectBuilder",
                "CalciferConfig",
                "StatisticLogger",
                "DSYMSymbolizer",
                "Checksum",
                "Toolkit"
            ]
        ),
        .testTarget(
            name: "RemoteCachePreparerTests",
            dependencies: [
                "RemoteCachePreparer"
            ]
        ),
        // MARK: BuildProductCacheStorage
        .target(
            name: "BuildProductCacheStorage",
            dependencies: [
                "XcodeProjectChecksumCalculator",
                "ZIPFoundation",
                "ArgumentsParser",
                "Toolkit"
            ]
        ),
        .testTarget(
            name: "BuildProductCacheStorageTests",
            dependencies: [
                "BuildProductCacheStorage"
            ]
        ),
        // MARK: BuildArtifacts
        .target(
            name: "BuildArtifacts",
            dependencies: [
                "XcodeProjectChecksumCalculator",
                "ArgumentsParser",
                "Toolkit"
            ]
        ),
        .testTarget(
            name: "BuildArtifactsTests",
            dependencies: [
                "BuildArtifacts"
            ]
        ),
        // MARK: XcodeProjectBuilder
        .target(
            name: "XcodeProjectBuilder",
            dependencies: [
                "ShellCommand",
                "CalciferConfig",
                "ArgumentsParser",
                "Toolkit"
            ]
        ),
        .testTarget(
            name: "XcodeProjectBuilderTests",
            dependencies: [
                "XcodeProjectBuilder",
                "Mock"
            ]
        ),
        // MARK: XcodeProjectChecksumCalculator
        .target(
            name: "XcodeProjCache",
            dependencies: [
                "XcodeProj",
                "Checksum"
            ]
        ),
        // MARK: XcodeProjectChecksumCalculator
        .target(
            name: "XcodeProjectChecksumCalculator",
            dependencies: [
                "ArgumentsParser",
                "XcodeProjCache",
                "XcodeProj",
                "Checksum"
            ]
        ),
        .testTarget(
            name: "XcodeProjectChecksumCalculatorTests",
            dependencies: [
                "XcodeProjectChecksumCalculator"
            ]
        ),
        // MARK: XcodeProjectPatcher
        .target(
            name: "XcodeProjectPatcher",
            dependencies: [
                "XcodeBuildEnvironmentParametersParser"
                "ArgumentsParser",
                "XcodeProjCache",
                "XcodeProj",
                "Toolkit"
            ]
        ),
        // MARK: DSYMSymbolizer
        .target(
            name: "DSYMSymbolizer",
            dependencies: [
                "ShellCommand",
                "ArgumentsParser",
                "Toolkit"
            ]
        ),
        .testTarget(
            name: "DSYMSymbolizerTests",
            dependencies: [
                "DSYMSymbolizer",
                "Mock"
            ]
        ),
        // MARK: XcodeBuildEnvironmentParametersParser
        .target(
            name: "XcodeBuildEnvironmentParametersParser",
            dependencies: [
                "ArgumentsParser",
                "Checksum",
                "Toolkit"
            ]
        ),
        .testTarget(
            name: "XcodeBuildEnvironmentParametersParserTests",
            dependencies: [
                "XcodeBuildEnvironmentParametersParser",
                "Toolkit"
            ]
        ),
        // MARK: Daemon
        .target(
            name: "Daemon",
            dependencies: [
                "RemoteCachePreparer",
                "CommandRunner",
                "ShellCommand",
                "Swifter"
            ]
        ),
        // MARK: CalciferConfig
        .target(
            name: "CalciferConfig",
            dependencies: [
                "Toolkit"
            ]
        ),
        // MARK: BuildStepIntegrator
        .target(
            name: "BuildStepIntegrator",
            dependencies: [
                "XcodeProj",
                "ArgumentsParser",
                "Toolkit"
            ]
        ),
        // MARK: Checksum
        .target(
            name: "Checksum",
            dependencies: [
                "Toolkit"
            ]
        ),
        // MARK: ShellCommand
        .target(
            name: "ShellCommand",
            dependencies: [
                "Toolkit"
            ]
        ),
        // MARK: Toolkit
        .target(
            name: "Toolkit",
            dependencies: [
                "SwiftyBeaver",
                "Utility"
            ]
        ),
        // MARK: Mock
        .target(
            name: "Mock",
            dependencies: [
                "ShellCommand"
            ],
            path: "Tests/Mock/"
        ),
    ]
)
