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

#if os(iOS)
/// 导航栏按钮的统一外观：图案或文字使用主文字色（与返回图标一致，浅色黑、深色白），不跟随 App 主色；
/// 按下时变淡，禁用时置灰。状态（例如已加星标）用实心与空心等图案区分，不另用颜色。
public struct SuiteToolbarButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        SuiteToolbarButtonLabel(configuration: configuration)
    }
}

private struct SuiteToolbarButtonLabel: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .foregroundStyle(.primary)
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.4 : 1) : 0.35)
    }
}

public extension View {
    /// 导航栏中的按钮、菜单与分享入口统一使用 ``SuiteToolbarButtonStyle``。
    ///
    /// 放在 `suiteToolbar { … }` 的每一项上；菜单（`Menu`）的标签同样改为主文字色。
    func suiteToolbarItemStyle() -> some View {
        buttonStyle(SuiteToolbarButtonStyle())
            .foregroundStyle(.primary)
    }
}
#endif

#if os(iOS)
/// 导航栏按钮组的统一尺寸。
public enum SuiteToolbarMetrics {
    /// 同一侧相邻图标之间的间距。
    public static let itemSpacing: CGFloat = 16
}

/// 导航栏右侧的多个按钮：放在同一个工具栏项中，图标之间固定留 ``SuiteToolbarMetrics/itemSpacing``，
/// 不依赖系统随版本变化的默认间距。按书写顺序从左到右排列。
///
/// 用在 `suiteToolbar { … }` 中，代替多个相邻的 `ToolbarItem(placement: .topBarTrailing)`。
public struct SuiteToolbarTrailingGroup<Content: View>: ToolbarContent {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: SuiteToolbarMetrics.itemSpacing) { content }
        }
    }
}
#endif
