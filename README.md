# HiIOS

HiIOS is a reusable iOS development library. It ships the same Swift modules through Swift Package Manager and CocoaPods so applications can select contracts and adapters separately. The current `dev` branch is the unreleased 4.x development line; the published 3.0.0 release remains unchanged.

| Family | Modules | Purpose |
| --- | --- | --- |
| Base | `HiIOSBase` | Platform independent models, failures, logging, analytics and social sharing contracts |
| Core | `HiIOSCore` | Common iOS colors, fonts, resources and device utilities |
| Net | `HiIOSNetCore`, `HiIOSNetRxSwift`, `HiIOSNetCombine` | HTTP contract, Moya transport and optional reactive adapters |
| Nav | `HiIOSNavCore`, `HiIOSNavRxSwift`, `HiIOSNavCombine` | Typed routes, validation and optional reactive adapters |
| Store | `HiIOSStoreCore`, `HiIOSStoreKeychain`, `HiIOSStoreDefaults`, `HiIOSStoreFile` | Storage contract and replaceable adapters |
| Suite | `HiIOSSuiteCore`, `HiIOSSuiteLogOSLog`, `HiIOSSuiteLogSwiftyBeaver` | Shared UI components and optional log sinks |

`HiIOSGHTrending` is an independent optional GitHub Trending module. The `HiIOS` convenience product combines Core, NetCombine, NavCombine, Store and SuiteCore, plus SFSafeSymbols. It does not build or link the RxSwift adapters or vendor SDKs by default; SwiftPM may still resolve package-wide dependencies declared for other optional products. Source files import their chosen modules explicitly.

## Installation

For development with SwiftPM, add this repository using the `dev` branch and select only the products your app needs. For CocoaPods development, use the independent podspecs from one local checkout. Because 4.x is not yet indexed by CocoaPods, a local Podfile must declare each HiIOS pod in the selected dependency chain with `:path`. After publication, `pod 'HiIOS'` will install the default bundle. A future public release will use a single matching tag and pod version; this development branch is not a published 4.x release.

```ruby
# Podfile, standalone Base from a local HiIOS checkout
pod 'HiIOSBase', :path => '/path/to/HiIOS'
```

The module graph is one way: Base has no internal dependency; Core uses Base; Net and Nav use Core; Store uses Base; SuiteCore uses Core, while logging adapters use Base. GitHub Trending uses NetCore. Direct third-party dependencies are pinned to exact versions in `Package.swift` and matching podspecs.

## Migrating from 3.x

| Previous import | New import |
| --- | --- |
| `HiIOSDevice` | `HiIOSStoreKeychain` or `HiIOSCore`, according to the API |
| `HiIOSLog` | `HiIOSBase` plus an optional `HiIOSSuiteLogOSLog` or `HiIOSSuiteLogSwiftyBeaver` sink |
| `HiIOSNavigation` | `HiIOSNavCore` |
| `HiIOSNetwork`, `HiIOSNetworkAlamofire` | `HiIOSNetCore` |
| `HiIOSPersistence` | `HiIOSStoreCore` and a selected adapter |
| `HiIOSGitHubTrending` | `HiIOSGHTrending` |

Logging uses `LogClient(sink: OSLogSink(subsystem:category:))`; the client redacts records before sending them to any sink. Applications keep their own authentication policy, user-facing copy and business models.

## Requirements

iOS 17+, Swift 6. Tests, simulator builds and local CocoaPods checks are required before a public release. This branch does not include a release tag or CocoaPods Trunk publication.
