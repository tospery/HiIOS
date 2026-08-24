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
        .library(name: "HiIOSNavigation", targets: ["HiIOSNavigation"]),
        .library(name: "HiIOSNetwork", targets: ["HiIOSNetwork"]),
        .library(name: "HiIOSNetworkAlamofire", targets: ["HiIOSNetworkAlamofire"]),
        .library(name: "HiIOSPersistence", targets: ["HiIOSPersistence"]),
        .library(name: "HiIOSDevice", targets: ["HiIOSDevice"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            "5.12.0"..<"6.0.0"
        )
    ],
    targets: [
        .target(name: "HiIOSCore"),
        .target(name: "HiIOSLog"),
        .target(name: "HiIOSNavigation"),
        .target(name: "HiIOSNetwork"),
        .target(
            name: "HiIOSNetworkAlamofire",
            dependencies: [
                "HiIOSLog",
                "HiIOSNetwork",
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
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
            name: "HiIOSNavigationTests",
            dependencies: ["HiIOSNavigation"]
        ),
        .testTarget(
            name: "HiIOSNetworkTests",
            dependencies: ["HiIOSNetwork"]
        ),
        .testTarget(
            name: "HiIOSNetworkAlamofireTests",
            dependencies: ["HiIOSNetwork", "HiIOSNetworkAlamofire"]
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
