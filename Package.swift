// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "goplaysdk",
    platforms: [
            .iOS(.v15)  // Setting the minimum iOS version to 15.0
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "goplaysdk",
            targets: ["goplaysdk"]),
    ],
    dependencies: [
            // JWTKit by Vapor
            .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.0.0"),
            .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "goplaysdk",
            dependencies: [
                            .product(name: "JWTKit", package: "jwt-kit"),
                            .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
                        ],
//           path: "Sources/goplaysdk", // This is where your views will go
            resources: [
                            .process("../images") // ✅ Add your image folder here
                        ]
        ),
        .testTarget(
            name: "goplaysdkTests",
            dependencies: ["goplaysdk"]
        )
    ]
)
