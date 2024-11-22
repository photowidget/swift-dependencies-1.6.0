// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-dependencies",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "Dependencies",
      targets: ["Dependencies"]
    ),
    .library(
      name: "DependenciesMacros",
      targets: ["DependenciesMacros"]
    ),
    .library(
      name: "DependenciesTestSupport",
      targets: ["DependenciesTestSupport"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/photowidget/combine-schedulers-1.0.2", branch: "release/1.0.2"),
    .package(url: "https://github.com/photowidget/swift-clocks-1.0.5", branch: "release/1.0.5"),
    .package(url: "https://github.com/photowidget/swift-concurrency-extras-1.3.0", branch: "release/1.3.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.4.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"601.0.0-prerelease"),
  ],
  targets: [
    .target(
      name: "DependenciesTestObserver",
      dependencies: [
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "Dependencies",
      dependencies: [
        .product(name: "Clocks", package: "swift-clocks-1.0.5"),
        .product(name: "CombineSchedulers", package: "combine-schedulers-1.0.2"),
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras-1.3.0"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "DependenciesTestSupport",
      dependencies: [
        "Dependencies",
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras-1.3.0"),
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "DependenciesTests",
      dependencies: [
        "Dependencies",
        "DependenciesTestSupport",
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
      ],
      exclude: ["Dependencies.xctestplan"]
    ),
    .target(
      name: "DependenciesMacros",
      dependencies: [
        "DependenciesMacrosPlugin",
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .macro(
      name: "DependenciesMacrosPlugin",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)

#if !os(macOS) && !os(WASI)
  package.products.append(
    .library(
      name: "DependenciesTestObserver",
      type: .dynamic,
      targets: ["DependenciesTestObserver"]
    )
  )
#endif

#if !os(WASI)
  package.dependencies.append(
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.0")
  )
  package.targets.append(contentsOf: [
    .testTarget(
      name: "DependenciesMacrosPluginTests",
      dependencies: [
        "Dependencies",
        "DependenciesMacros",
        "DependenciesMacrosPlugin",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
  ])
#endif

#if !os(Windows)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  )
#endif
