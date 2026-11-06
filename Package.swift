// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HiIOS",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HiIOSBase", targets: ["HiIOSBase"]),
        .library(name: "HiIOSCore", targets: ["HiIOSCore"]),
        .library(name: "HiIOSNet", targets: ["HiIOSNetCore"]),
        .library(name: "HiIOSNetCore", targets: ["HiIOSNetCore"]),
        .library(name: "HiIOSNetRxSwift", targets: ["HiIOSNetRxSwift"]),
        .library(name: "HiIOSNetCombine", targets: ["HiIOSNetCombine"]),
        .library(name: "HiIOSNav", targets: ["HiIOSNavCore"]),
        .library(name: "HiIOSNavCore", targets: ["HiIOSNavCore"]),
        .library(name: "HiIOSNavRxSwift", targets: ["HiIOSNavRxSwift"]),
        .library(name: "HiIOSNavCombine", targets: ["HiIOSNavCombine"]),
        .library(
            name: "HiIOSStore",
            targets: ["HiIOSStoreCore", "HiIOSStoreKeychain", "HiIOSStoreDefaults", "HiIOSStoreFile"]
        ),
        .library(name: "HiIOSStoreCore", targets: ["HiIOSStoreCore"]),
        .library(name: "HiIOSStoreKeychain", targets: ["HiIOSStoreKeychain"]),
        .library(name: "HiIOSStoreDefaults", targets: ["HiIOSStoreDefaults"]),
        .library(name: "HiIOSStoreFile", targets: ["HiIOSStoreFile"]),
        .library(name: "HiIOSSuite", targets: ["HiIOSSuiteCore"]),
        .library(name: "HiIOSSuiteCore", targets: ["HiIOSSuiteCore"]),
        .library(name: "HiIOSSuiteLogOSLog", targets: ["HiIOSSuiteLogOSLog"]),
        .library(name: "HiIOSSuiteLogSwiftyBeaver", targets: ["HiIOSSuiteLogSwiftyBeaver"]),
        .library(name: "HiIOSGHTrending", targets: ["HiIOSGHTrending"]),
        .library(
            name: "HiIOS",
            targets: [
                "HiIOS", "HiIOSCore", "HiIOSNetCombine", "HiIOSNavCombine",
                "HiIOSStoreCore", "HiIOSStoreKeychain", "HiIOSStoreDefaults",
                "HiIOSStoreFile", "HiIOSSuiteCore"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", exact: "8.0.0"),
        .package(url: "https://github.com/devicekit/DeviceKit.git", exact: "5.10.0"),
        .package(url: "https://github.com/Moya/Moya.git", exact: "15.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.12.2"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", exact: "6.9.0"),
        .package(url: "https://github.com/tospery/URLNavigator.git", exact: "2.5.1-v1"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", exact: "2.1.1"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", exact: "7.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", exact: "2.11.3")
    ],
    targets: [
        .target(name: "HiIOSBase"),
        .target(name: "HiIOSCore", dependencies: [
            "HiIOSBase", .product(name: "SwifterSwift", package: "SwifterSwift"),
            .product(name: "DeviceKit", package: "DeviceKit")
        ]),
        .target(name: "HiIOSNetCore", dependencies: [
            "HiIOSCore", .product(name: "Moya", package: "Moya"),
            .product(name: "Alamofire", package: "Alamofire")
        ]),
        .target(name: "HiIOSNetRxSwift", dependencies: [
            "HiIOSNetCore", .product(name: "RxMoya", package: "Moya"),
            .product(name: "RxSwift", package: "RxSwift")
        ]),
        .target(name: "HiIOSNetCombine", dependencies: [
            "HiIOSNetCore", .product(name: "CombineMoya", package: "Moya")
        ]),
        .target(name: "HiIOSNavCore", dependencies: ["HiIOSCore"]),
        .target(name: "HiIOSNavRxSwift", dependencies: [
            "HiIOSNavCore", .product(name: "RxSwift", package: "RxSwift"),
            .product(name: "URLNavigator", package: "URLNavigator")
        ]),
        .target(name: "HiIOSNavCombine", dependencies: ["HiIOSNavCore"]),
        .target(name: "HiIOSStoreCore", dependencies: ["HiIOSBase"]),
        .target(name: "HiIOSStoreKeychain", dependencies: ["HiIOSStoreCore", "HiIOSBase"]),
        .target(name: "HiIOSStoreDefaults", dependencies: ["HiIOSStoreCore"]),
        .target(name: "HiIOSStoreFile", dependencies: ["HiIOSStoreCore"]),
        .target(name: "HiIOSSuiteCore", dependencies: ["HiIOSCore"]),
        .target(name: "HiIOS", dependencies: [.product(name: "SFSafeSymbols", package: "SFSafeSymbols")]),
        .target(name: "HiIOSSuiteLogOSLog", dependencies: ["HiIOSBase"]),
        .target(name: "HiIOSSuiteLogSwiftyBeaver", dependencies: [
            "HiIOSBase", .product(name: "SwiftyBeaver", package: "SwiftyBeaver")
        ]),
        .target(name: "HiIOSGHTrending", dependencies: [
            "HiIOSNetCore", .product(name: "SwiftSoup", package: "SwiftSoup")
        ]),
        .testTarget(name: "HiIOSBaseTests", dependencies: ["HiIOSBase"]),
        .testTarget(name: "HiIOSCoreTests", dependencies: ["HiIOSCore"]),
        .testTarget(name: "HiIOSNetCoreTests", dependencies: ["HiIOSNetCore"]),
        .testTarget(name: "HiIOSNetRxSwiftTests", dependencies: ["HiIOSNetRxSwift", "HiIOSNetCore"]),
        .testTarget(name: "HiIOSNetCombineTests", dependencies: ["HiIOSNetCombine", "HiIOSNetCore"]),
        .testTarget(name: "HiIOSNavCoreTests", dependencies: ["HiIOSNavCore"]),
        .testTarget(name: "HiIOSNavRxSwiftTests", dependencies: ["HiIOSNavRxSwift", "HiIOSNavCore"]),
        .testTarget(name: "HiIOSNavCombineTests", dependencies: ["HiIOSNavCombine", "HiIOSNavCore"]),
        .testTarget(name: "HiIOSStoreCoreTests", dependencies: ["HiIOSStoreCore"]),
        .testTarget(name: "HiIOSStoreKeychainTests", dependencies: ["HiIOSStoreCore", "HiIOSStoreKeychain"]),
        .testTarget(name: "HiIOSStoreDefaultsTests", dependencies: ["HiIOSStoreCore", "HiIOSStoreDefaults"]),
        .testTarget(name: "HiIOSStoreFileTests", dependencies: ["HiIOSStoreCore", "HiIOSStoreFile"]),
        .testTarget(name: "HiIOSSuiteCoreTests", dependencies: ["HiIOSSuiteCore"]),
        .testTarget(name: "HiIOSSuiteLogOSLogTests", dependencies: ["HiIOSSuiteLogOSLog", "HiIOSBase"]),
        .testTarget(name: "HiIOSSuiteLogSwiftyBeaverTests", dependencies: [
            "HiIOSSuiteLogSwiftyBeaver", "HiIOSBase",
            .product(name: "SwiftyBeaver", package: "SwiftyBeaver")
        ]),
        .testTarget(name: "HiIOSGHTrendingTests", dependencies: ["HiIOSGHTrending", "HiIOSNetCore"])
    ],
    swiftLanguageModes: [.v6]
)
