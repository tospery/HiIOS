# HiIOS 依赖准入与历史参考

HiIOS 同时通过 SwiftPM 与 CocoaPods 分发；新增或升级直接依赖时，核对两个渠道均可安装的同一稳定版本、许可证、维护状态、平台支持、并发安全、隐私数据流、传递依赖、二进制与启动成本。`Package.swift` 与对应 podspec 的版本须一致，不能靠某个消费 App 的 `Package.resolved` 或 `Podfile.lock` 掩盖分发差异。构建插件和宏须先审查来源与权限，不用跳过验证参数绕过审查。

| 依赖 | 本库当前归属 |
| --- | --- |
| Alamofire | Moya 的底层依赖；类型不穿透 HiIOS 自有接口 |
| Moya | `HiIOSNetCore` 的默认 transport；RxSwift 与 Combine adapter 独立 |
| DeviceKit | 仅用于 `HiIOSCore` 的设备描述，不把设备型号当身份 |
| SwifterSwift | 当前 SPM 只提供整体 product，故仅在 Core 使用；Base 保持纯净 |
| SwiftyBeaver | 仅在可选 `HiIOSSuiteLogSwiftyBeaver` adapter 使用 |
| SFSafeSymbols | 仅由 `HiIOS` 便捷入口聚合 |
| SwiftSoup | 仅用于 `HiIOSGHTrending` 的 HTML parser |
| URLNavigator-Hi | 当前固定 `2.5.1-v1`，仅由 `HiIOSNavRxSwift` 使用 |
| FCUUID | 缺少可核对的同版双分发，不进入本库 |

这些是当前产品选择，采用或升级前仍需核对实际分发源和当前平台支持。不为未来可能的 adapter 预装依赖，不把第三方公共类型固化进通用契约。

旧 HiBase、HiCore、HiMapper、HiLog、HiStats、HiResource、HiRealm、HiNav、HiNet、HiTrending、HiSwiftUI 与 HiGit_iOS 仅作为用户明确要求时的历史参考，不是当前构建输入或 API 兼容事实源。只借鉴功能与交互意图；不复制旧的明文日志、全局 mutable singleton、dispose bag、method swizzling、force unwrap、静默失败为空数组或缺少测试的传输与持久化实现。旧 HiTrending 与 HiSwiftUI 的能力须按当前模块和隐私边界重新评估。
