# HiIOS 智能体协作说明

HiIOS（专名“HiIOS 效率库”，规则与文档叙述使用该专名，仓库名、product、Pod 与代码标识符保持原样）是独立于 AtlasHub 业务的 iOS 效率库，同时提供 Swift Package Manager 与 CocoaPods 分发。修改模块、公开 API、依赖或文档前，先确认工作树状态并保留无关改动；具体产品边界见 [`docs/architecture/products.md`](docs/architecture/products.md)。文档归属与入口见 [`docs/README.md`](docs/README.md)。

## 硬边界

- 六个基础家族为 Base、Core、Net、Nav、Store、Suite；GitHub Trending 是独立可选产品，`HiIOS` 是便捷入口。业务 Feature、认证策略、用户文案和品牌不进入本库。
- `Package.swift` 是 SwiftPM product、target 与资源图的事实源；独立 Pod 与公开 Swift module 对应。同一公开版本的 SPM 与 CocoaPods 行为和依赖版本需一致，不覆盖已发布 tag/spec。
- 本库目前只由维护者本人直接使用，不保留版本兼容：公开 API、product 与行为可直接做破坏性调整，不留废弃别名、兼容分支或迁移层，也不要求升主版本或撰写迁移说明；消费项目同批更新并验证。
- 修改公开接口、模块或依赖时，验证受影响的 SPM product、独立 Pod、聚合 Pod、资源及消费者；发布前核对两种分发方式，不能以本地 lint 代替公开发布验收。
- 新增或升级第三方依赖时，读取 [`docs/engineering/dependencies.md`](docs/engineering/dependencies.md)。
- 日志默认经脱敏策略处理；是否脱敏由消费项目通过 `LogRedactionPolicy` 等参数显式选择并自负其责，本库不内置渠道、环境或加密策略。厂商 SDK 不进入默认产品，未经实际可用的双分发验证不预建空 target。

## 消费项目的同级源码依赖

消费项目选择 SwiftPM local package 的同级源码检出时，必须遵守 [`docs/engineering/sibling-source-dependency.md`](docs/engineering/sibling-source-dependency.md) 的版本锁和 Git 对齐门禁，并将其接入实际 Verification、CI 与 Archive/Release 入口。本库不规定消费项目的锁文件名、scheme 或签名配置。

GitHub Trending 的独立限制见 [`docs/engineering/gh-trending.md`](docs/engineering/gh-trending.md)。
