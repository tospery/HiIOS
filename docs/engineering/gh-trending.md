# HiIOSGHTrending 独立产品

`HiIOSGHTrending` 的 SPM product、target、Swift module 与独立 Pod 同名，聚合 Pod 的显式入口为 `HiIOS/GHTrending`。它跟随 HiIOS 统一版本，但不进入 Suite、默认聚合入口或其他项目的基础依赖。

- 公开 API 只暴露自有值、查询条件、错误、parser 与可注入 client；SwiftSoup 类型不穿透边界。SwiftSoup 的 SPM/CocoaPods 版本和行为保持一致。
- GitHub 没有公开 Trending API；`/trending` 是未版本化 HTML 页面。GitHub Search API 结果须称为 Popular Repositories。
- 库本身不自动发起线上抓取：是否在生产装配 live client 由消费项目在其 Composition Root 决定并记录（AtlasHub_iOS 自 2026-11-11 起装配，见其 ADR-0010）。库交付模型、parser、去标识 fixture 与注入式 client 契约。
- 不使用代理绕过、登录 Cookie/token 抓取、高频轮询、批量预取或限流绕过；不记录完整 HTML 或个人信息。
- Live adapter 固定 `github.com` origin，合并并缓存请求，支持 ETag/条件请求，遵守 403、429 和 `Retry-After`。
- 至少区分 HTTP 状态、内容类型不支持、结构变化、限流、取消和真实空结果；错误不转换成空数组。
- 测试使用自建最小化去标识 HTML fixture，覆盖 DOM 变化、缺失 selector、部分损坏、Unicode、空结果、非 2xx、重定向、限流和取消。Live 页面检查仅用于低频手工或受控 nightly 验收。
- 旧 `HiTrending` 仅用于用户明确要求的历史对照；不复制其 singleton、CSS selector 堆叠、静默空数组、`URLSession.shared` 或字符串拼 URL。
- Trending Developers 与仓库榜单同为受支持的解析目标；开发者条目的热门仓库位于嵌套 `article` 的标题链接。若消费项目使用 Search API 驱动的列表，应明确命名为 Popular Repositories。
- 头像只接受 GitHub 自有图片域（`*.githubusercontent.com`）的 HTTPS 地址；计数解析失败返回 nil，不以 0 代替。
- 保存到本机的真实页面可通过 `HIIOS_GH_TRENDING_HTML_DIR`（模拟器测试用 `TEST_RUNNER_` 前缀）交给 `parserReadsLocallySavedLivePages` 做低频手工检查，该测试不访问网络。
