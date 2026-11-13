import SwiftUI

#if os(iOS)
public extension View {
    /// 传统导航栏：标准高度，标题居中显示，不使用大标题。
    ///
    /// 所有页面统一使用它设置标题，避免各页面自行组合 `navigationTitle` 与显示模式而出现大小不一的导航栏。
    func suiteNavigationTitle(_ title: some StringProtocol) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }

    /// 只使用传统导航栏高度而不设置文字标题，用于标题由工具栏自定义内容承担的页面。
    func suiteNavigationBar() -> some View {
        navigationBarTitleDisplayMode(.inline)
    }
}
#endif
