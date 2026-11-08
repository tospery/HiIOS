# HiIOS 产品与双分发

## 产品边界

HiIOS 的 `dev` 分支是尚未公开发布的 4.x 开发线；已发布的 3.0.0 tag/spec 保持不变。4.x 源码提交、Git tag 和 CocoaPods Trunk 发布是不同操作。当前最低平台为 iOS 17，语言模式为 Swift 6；平台基线变更需单独验证。

| 家族 | 模块与职责 | 内部依赖 |
| --- | --- | --- |
| Base | `HiIOSBase`：纯 Swift 模型、错误、日志、统计和社会化分享契约 | 无 |
| Core | `HiIOSCore`：颜色、字体、资源、序列化、文件和设备工具 | Base |
| Net | `HiIOSNetCore` 与 RxSwift、Combine adapter：HTTP 契约和 Moya transport | NetCore → Core；adapter → NetCore |
| Nav | `HiIOSNavCore` 与 RxSwift、Combine adapter：typed route、URL 校验和通用展示状态 | NavCore → Core；adapter → NavCore |
| Store | `HiIOSStoreCore` 与 Keychain、Defaults、File adapter：字节存储与安全值契约 | StoreCore → Base；adapter → StoreCore |
| Suite | `HiIOSSuiteCore` 与 OSLog、SwiftyBeaver adapter：通用 SwiftUI 视图与日志输出 | SuiteCore → Core；日志 adapter → Base |

`HiIOSGHTrending` 是依赖 `HiIOSNetCore` 的独立可选产品，不属于六个基础家族。`HiIOS` 便捷入口组合 Core、NetCombine、NavCombine、Store、SuiteCore 与 SFSafeSymbols；不默认链接 RxSwift、Trending 或厂商 SDK。SwiftPM 仍可能解析 manifest 中其他可选 target 的外部依赖。源码显式导入所选模块，不通过 `@_exported import` 隐式重导出。

## 双分发规则

- `Package.swift` 是源码、resources、平台、product 与 target 图的首要事实源。真实子模块使用对应的 SPM product、Swift target/module 和独立 root podspec；聚合 product/pod 只提供安装选择，CocoaPods subspec 不替代独立 Swift module。
- 同一 HiIOS 公开版本的 podspec 共用版本与 Git tag；直接第三方依赖在两个包管理器使用行为一致的固定稳定版本。应用通过自身的依赖解析锁与 HiIOS 版本锁固定完整依赖图。
- Base 保持无平台、UI 和 SwifterSwift 依赖；当前 SwifterSwift 的 SPM product 只由 Core 使用。DeviceKit 属于 Core，SwiftyBeaver 属于可选 Suite adapter。缺少可核对双分发源的依赖不进入默认产品。
- 友盟、EMAS 等厂商 adapter 只有在 SPM 与 CocoaPods 都具备可验证来源时才实现，不预建空 target，也不由默认入口初始化。

每次变更分别验证受影响的 SPM product、独立 Pod 和聚合 Pod；隔离安装 Core、RxSwift、Combine 与默认入口，检查 Swift module 名、公开接口、资源定位、依赖环、取消与错误语义、隐私脱敏。CocoaPods 本地 lint 不是公开 Trunk 发布。
