// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HiIOS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "HiIOSCore", targets: ["HiIOSCore"]),
        .library(name: "HiIOSLog", targets: ["HiIOSLog"]),
        .library(name: "HiIOSPersistence", targets: ["HiIOSPersistence"]),
        .library(name: "HiIOSDevice", targets: ["HiIOSDevice"])
    ],
    targets: [
        .target(name: "HiIOSCore"),
        .target(name: "HiIOSLog"),
        .target(
            name: "HiIOSPersistence",
            dependencies: ["HiIOSCore"]
        ),
        .target(
            name: "HiIOSDevice",
            dependencies: ["HiIOSCore", "HiIOSPersistence"]
        ),
        .testTarget(
            name: "HiIOSCoreTests",
            dependencies: ["HiIOSCore"]
        ),
        .testTarget(
            name: "HiIOSLogTests",
            dependencies: ["HiIOSDevice", "HiIOSLog"]
        ),
        .testTarget(
            name: "HiIOSPersistenceTests",
            dependencies: ["HiIOSCore", "HiIOSPersistence"]
        ),
        .testTarget(
            name: "HiIOSDeviceTests",
            dependencies: ["HiIOSCore", "HiIOSDevice", "HiIOSPersistence"]
        )
    ],
    swiftLanguageModes: [.v6]
)
