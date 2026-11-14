import SwiftUI

#if os(iOS)
/// ``SuitePagerTabs`` 中的一页；标题由使用方提供并负责本地化。
public struct SuitePagerTab<Tag: Hashable>: Identifiable {
    public let tag: Tag
    public let title: String
    public let accessibilityIdentifier: String?

    public var id: Tag { tag }

    public init(tag: Tag, title: String, accessibilityIdentifier: String? = nil) {
        self.tag = tag
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

/// 顶部标签与可左右滑动翻页的内容区。
///
/// 标签等宽铺满一行（每个至少能放下自身文字），放不下时整行横向滚动；选中项使用当前 tint，
/// 下方是与文字同宽、3pt 高的指示条，切换时滑动过去。左右滑动内容会同步选中标签，点击标签会翻到对应页。
/// 各页在切换时保留，不重新创建。标签栏背景透明，与页面画布融为一体，不画底部分隔线。
public struct SuitePagerTabs<Tag: Hashable, Page: View>: View {
    public static var tabHeight: CGFloat { 48 }

    private let tabs: [SuitePagerTab<Tag>]
    @Binding private var selection: Tag
    private let page: (Tag) -> Page

    @State private var availableWidth: CGFloat = 0
    @Namespace private var indicator

    public init(
        tabs: [SuitePagerTab<Tag>], selection: Binding<Tag>, @ViewBuilder page: @escaping (Tag) -> Page
    ) {
        self.tabs = tabs
        self._selection = selection
        self.page = page
    }

    public var body: some View {
        VStack(spacing: 0) {
            tabBar
            TabView(selection: $selection) {
                ForEach(tabs) { tab in
                    page(tab.tag).tag(tab.tag)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }

    private var tabBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(tabs) { tab in
                        tabButton(tab).id(tab.tag)
                    }
                }
                .frame(minWidth: availableWidth)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { availableWidth = $0 }
            .onChange(of: selection) { _, newValue in
                withAnimation(.easeInOut(duration: 0.25)) { proxy.scrollTo(newValue, anchor: .center) }
            }
        }
        .frame(height: Self.tabHeight)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("suite.pagerTabs")
    }

    private func tabButton(_ tab: SuitePagerTab<Tag>) -> some View {
        let isSelected = tab.tag == selection
        let minimumWidth = tabs.isEmpty ? 0 : availableWidth / CGFloat(tabs.count)
        return Button {
            withAnimation(.easeInOut(duration: 0.25)) { selection = tab.tag }
        } label: {
            SuitePagerTabLabel(
                title: tab.title, isSelected: isSelected, minimumWidth: minimumWidth,
                height: Self.tabHeight, indicator: indicator)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .modifier(SuitePagerTabIdentifier(identifier: tab.accessibilityIdentifier))
    }
}

/// 标签文字与选中指示条；指示条与文字同宽、贴在标签底部，在各标签之间滑动。
private struct SuitePagerTabLabel: View {
    let title: String
    let isSelected: Bool
    let minimumWidth: CGFloat
    let height: CGFloat
    let indicator: Namespace.ID
    @State private var textWidth: CGFloat = 0

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .lineLimit(1)
            .fixedSize()
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { textWidth = $0 }
            .padding(.horizontal, 8)
            .frame(minWidth: minimumWidth, minHeight: height)
            .overlay(alignment: .bottom) {
                if isSelected {
                    UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3, style: .continuous)
                        .fill(.tint)
                        .frame(width: textWidth, height: 3)
                        .matchedGeometryEffect(id: "indicator", in: indicator)
                }
            }
            .contentShape(Rectangle())
    }
}

private struct SuitePagerTabIdentifier: ViewModifier {
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
