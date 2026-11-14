import SwiftUI

#if os(iOS)
public extension View {
    /// 传统导航栏的工具栏：其中每一项只显示图标或文字本身，不带 iOS 26 起的玻璃圆圈或胶囊背景。
    ///
    /// 用法与 `toolbar(content:)` 相同，页面统一用它代替 `.toolbar { … }`，不在页面中自行判断系统版本。
    /// 版本判断放在视图层而不是 `ToolbarContentBuilder` 中：后者的 `buildLimitedAvailability` 位于 SwiftUICore，
    /// 动态库产品无法直接链接。
    func suiteToolbar<Content: ToolbarContent>(@ToolbarContentBuilder content: () -> Content) -> some View {
        modifier(SuitePlainToolbarModifier(content: content()))
    }
}

private struct SuitePlainToolbarModifier<Items: ToolbarContent>: ViewModifier {
    let content: Items

    func body(content view: Content) -> some View {
        if #available(iOS 26.0, *) {
            view.toolbar { content.sharedBackgroundVisibility(.hidden) }
        } else {
            view.toolbar { content }
        }
    }
}
#endif
