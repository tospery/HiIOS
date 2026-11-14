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

## SuiteCore 页面外观组件

`HiIOSSuiteCore` 提供与业务、品牌无关的页面外观约定，消费项目在所有页面统一使用，不在页面中各自组合系统修饰符：

- **传统导航栏**：`suiteNavigationTitle(_:)` 设置标准高度、标题居中的导航栏，不使用大标题；标题由工具栏自定义内容承担时用 `suiteNavigationBar()`。
- **页面画布与内容表面**：`Color.suitePageCanvas`（浅灰，深色下纯黑）与 `Color.suiteContentSurface`（白色，深色下深灰）始终有色差。整页用 `suitePageCanvas()`；平铺列表用 `suiteListCanvas()` 并为内容行加 `suiteListRowSurface()`；阅读页的正文、评论等内容块用 `suiteContentBlock(padding:)`，块间露出画布。
- **分页尾**：`LoadMoreFooter` 按 `LoadMoreState`（加载中、加载更多、已全部加载、失败）显示列表底部状态，文案由 `LoadMoreLabels` 提供；在 `List` 中自身无分隔线、透明行背景。`LoadMoreLabels.finished` 为空时全部加载后不显示结尾文字。
- **列表分组与行**：`SuiteListSection`、`SuiteListRow`、`SuiteListButtonRow` 与 `SuiteListStyle`；单行最小高度为 `SuiteListRowMetrics.minimumHeight`（52pt，与 iOS 26 系统列表一致）。
- **工具栏**：页面用 `suiteToolbar { … }` 代替 `.toolbar { … }`，其中每一项只显示图标或文字本身，不带 iOS 26 起的玻璃背景。版本判断放在视图层：`ToolbarContentBuilder` 中的 `if #available` 会引用位于 SwiftUICore 的 `buildLimitedAvailability`，动态库产品无法链接。
- **工具栏按钮外观**：`suiteToolbarItemStyle()`（`SuiteToolbarButtonStyle`）让导航栏中的按钮、菜单与分享入口使用主文字色，与返回图标一致；按下变淡、禁用置灰。
- **页面首屏加载**：`SuitePageLoadingView` 只显示放大一档的加载动画，不显示文字；动画由 `SuiteActivityIndicator` 绘制，颜色取当前 `tint`。说明文字通过 `accessibilityLabel` 交给 VoiceOver。
- **翻页标签**：`SuitePagerTabs` 与 `SuitePagerTab` 提供顶部可横向滚动的等宽标签（选中项 tint 色、与文字同宽的 3pt 指示条）和可左右滑动的分页内容。
- **锚定气泡**：`suiteAnchoredTooltip(text:anchor:reservedTop:autoDismissAfter:onDismiss:)` 在视图上显示指向锚点的反色气泡，上方空间不足时显示在下方；默认 5 秒后 0.3 秒渐隐。位置计算 `SuiteAnchoredTooltipLayout` 独立可测。
- **传统标签栏**：`SuiteTabBar` 与 `SuiteTabBarItem` 绘制与屏幕同宽的通栏标签栏（内容高 `SuiteTabBar.height`，背景延伸到底部安全区；`itemOffset` 可让图标与文字整体下移）。iOS 26 起系统标签栏只有悬浮玻璃样式，需要通栏样式的项目隐藏系统标签栏，把它以 `safeAreaInset(edge: .bottom, spacing: 0)` 挂在各 Tab 导航栈的根页上，push 时随根页滑出。
