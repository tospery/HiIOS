import SwiftUI

#if os(iOS)
/// ``SuiteTabBar`` 中的一项；标题由使用方提供并负责本地化。
public struct SuiteTabBarItem<Tag: Hashable>: Identifiable {
    public let tag: Tag
    public let title: String
    public let systemImage: String
    public let accessibilityIdentifier: String?

    public var id: Tag { tag }

    /// - Parameter systemImage: SF Symbol 名称，显示时统一使用实心样式。
    public init(tag: Tag, title: String, systemImage: String, accessibilityIdentifier: String? = nil) {
        self.tag = tag
        self.title = title
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

/// 传统样式的底部标签栏：与屏幕同宽，系统栏材质背景，顶部一条细分隔线，选中项使用当前 tint。
///
/// iOS 26 起系统 `TabView` 的标签栏固定为悬浮玻璃样式，需要传统通栏样式时隐藏系统标签栏并使用本视图。
/// 通常以 `safeAreaInset(edge: .bottom, spacing: 0)` 挂在各 Tab 导航栈的根页上：push 时随根页一起滑出，
/// 返回根页时随之出现。背景延伸到底部安全区；标签文字与系统标签栏一样不随动态字体放大，
/// 长按时通过大号内容查看器显示。
public struct SuiteTabBar<Tag: Hashable>: View {
    /// 标签栏内容高度，不含底部安全区。
    public static var height: CGFloat { 49 }

    private let items: [SuiteTabBarItem<Tag>]
    private let selection: Tag
    private let onSelect: @MainActor (Tag) -> Void

    /// - Parameter onSelect: 点击某一项时执行，包括再次点击当前项。
    public init(items: [SuiteTabBarItem<Tag>], selection: Tag, onSelect: @escaping @MainActor (Tag) -> Void) {
        self.items = items
        self.selection = selection
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                button(for: item)
            }
        }
        .frame(height: Self.height)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) { Divider() }
        .background(.bar, ignoresSafeAreaEdges: .bottom)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("suite.tabBar")
    }

    private func button(for item: SuiteTabBarItem<Tag>) -> some View {
        let isSelected = item.tag == selection
        return Button {
            onSelect(item.tag)
        } label: {
            VStack(spacing: 2) {
                Image(systemName: item.systemImage)
                    .symbolVariant(.fill)
                    .font(.system(size: 22))
                    .frame(height: 26)
                Text(item.title)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(uiColor: .systemGray)))
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityShowsLargeContentViewer {
            Image(systemName: item.systemImage).symbolVariant(.fill)
            Text(item.title)
        }
        .modifier(OptionalAccessibilityIdentifier(identifier: item.accessibilityIdentifier))
    }
}

private struct OptionalAccessibilityIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}
#endif
