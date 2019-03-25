// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VaporDemo",
    products: [
        .library(name: "VaporDemo", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on mysql
        .package(url:"https://github.com/vapor/fluent-mysql.git",from:"3.0.1"),
        .package(url:"https://github.com/krzyzanowskim/CryptoSwift.git",from:"0.14.0"),
        //mail Server
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP.git", from: "4.0.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["SwiftSMTP","FluentMySQL", "Vapor","CryptoSwift"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

