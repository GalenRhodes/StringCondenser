// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//@f:0
let package = Package(
  name: "StringCondenser",
  platforms: [
      .macOS(.v10_15),
      .tvOS(.v13),
      .iOS(.v13),
      .watchOS(.v6),
  ],
  products: [
      .executable(name: "StringCondenser", targets: [ "StringCondenser" ]),
  ],
  dependencies: [
      .package(name: "Rubicon", url: "https://github.com/GalenRhodes/Rubicon", .upToNextMinor(from: "0.8.0")),
      .package(name: "RedBlackTree", url: "https://github.com/GalenRhodes/RedBlackTree", .upToNextMajor(from: "2.0.3")),
      .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.1")),
      .package(name: "SourceKitten", url: "https://github.com/jpsim/SourceKitten", .upToNextMinor(from: "0.31.1")),
  ],
  targets: [
      .executableTarget(name: "StringCondenser", dependencies: [ "Rubicon", "RedBlackTree", "swift-argument-parser", "SourceKitten", ]),
  ]
)
//@f:1
