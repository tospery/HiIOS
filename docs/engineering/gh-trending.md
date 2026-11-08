# HiIOSGHTrending 独立产品

`HiIOSGHTrending` 的 SPM product、target、Swift module 与独立 Pod 同名，聚合 Pod 的显式入口为 `HiIOS/GHTrending`。它跟随 HiIOS 统一版本，但不进入 Suite、默认聚合入口或其他项目的基础依赖。

- 公开 API 只暴露自有值、查询条件、错误、parser 与可注入 client；SwiftSoup 类型不穿透边界。SwiftSoup 的 SPM/CocoaPods 版本和行为保持一致。
- GitHub 没有公开 Trending API；`/trending` 是未版本化 HTML 页面。GitHub Search API 结果须称为 Popular Repositories。
- 未获 GitHub Support/合规确认前，不在生产默认启用 live scraper。可以交付模型、parser、去标识 fixture 与注入式 client 契约。
- 不使用代理绕过、登录 Cookie/token 抓取、高频轮询、批量预取或限流绕过；不记录完整 HTML 或个人信息。
- Live adapter 固定 `github.com` origin，合并并缓存请求，支持 ETag/条件请求，遵守 403、429 和 `Retry-After`。
- 至少区分 HTTP 状态、内容类型不支持、结构变化、限流、取消和真实空结果；错误不转换成空数组。
- 测试使用自建最小化去标识 HTML fixture，覆盖 DOM 变化、缺失 selector、部分损坏、Unicode、空结果、非 2xx、重定向、限流和取消。Live 页面检查仅用于低频手工或受控 nightly 验收。
- 旧 `HiTrending` 仅用于用户明确要求的历史对照；不复制其 singleton、CSS selector 堆叠、静默空数组、`URLSession.shared` 或字符串拼 URL。
- 4.0 首版暂缓 Trending Developers；若消费项目要先交付热门仓库，应将 Search API 驱动的能力明确命名为 Popular Repositories。
