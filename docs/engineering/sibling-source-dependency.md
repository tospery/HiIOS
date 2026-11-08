# 消费项目的同级源码依赖门禁

本规则适用于选择 SwiftPM local package 直接编译 HiIOS 源码的任何消费项目。按发布 tag 远程解析的 SwiftPM 依赖和已发布 CocoaPods 制品不适用。

## 布局与版本身份

- 将 HiIOS 作为独立 Git 仓库检出在消费仓库的同级目录，以 `.package(path:)` 接入公开 SPM products；不以内嵌 submodule 和 gitlink 作为当前方案。
- 消费仓库提交版本锁，记录 HiIOS 的公开 HTTPS 地址和 **40 位完整 commit SHA**。分支、tag、CocoaPods 版本、本地 HEAD 或未提交文件不能代替该锁。
- 优先解析消费仓库同级 `HiIOS/`；linked worktree 可回落到主 worktree 同级目录。非标准绝对路径只改变检出位置，不放宽校验。
- App 自身的业务 target 只依赖公开 products，不直接引用 `HiIOS/Sources/` 内部路径。

## 必须接入的硬性门禁

| 入口 | 必须阻断的状态 |
| --- | --- |
| Verification、CI | 缺少检出或无效锁；HEAD 与锁定 SHA 不同；HiIOS 工作区有已暂存、未暂存或未跟踪改动 |
| Archive、Export、Release 上传或发布 | 上述任一状态；锁定 SHA 不在可信远端跟踪分支上 |
| Debug 与 IDE | 可使用偏离版本锁的源码，但须明确警告；这类结果不能作为锁定版本的验收证据 |

检查必须成为实际验证与发布入口的前置步骤，失败时阻断后续动作；仅在说明文档写“发布前运行”不构成硬门禁。Xcode scheme pre-action 若不能阻断 Archive，不得把它宣称为门禁；应使用可失败即停止的 Archive 包装入口或经验证的构建阶段。消费项目须明确只支持受门禁保护的发布入口。远端可达性判断使用可信 remote-tracking refs，必要时先 fetch。

## 更新顺序与验证

1. 在 HiIOS 提交并推送修改，确认 SHA 可从可信远端到达。
2. 消费仓库更新版本锁到该 SHA。
3. 分别运行 HiIOS 的 SPM/CocoaPods 门禁和消费项目根门禁，并验证锁不一致、工作区不干净及 Release 未推送时的失败分支。
4. 最后提交并推送消费仓库版本锁。不得让远端消费提交指向尚未推送的 HiIOS 提交。

新机器和云端环境应提供 bootstrap 操作，用锁中的 HTTPS 地址检出指定 SHA；开发环境可提供 status 与 lock 操作。AtlasHub_iOS 的脚本和锁文件只是一个消费实例。
