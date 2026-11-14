import SwiftUI

#if os(iOS)
/// ``SuitePager`` 的翻页手感约定。
public enum SuitePagerMetrics {
    /// 松手时拖动距离达到页宽的这一比例即翻到相邻页。系统分页需要拖过半页，这里明显更容易切换。
    public static let defaultSwipeThreshold: CGFloat = 0.2
}

/// 可左右滑动翻页的内容区，选中页与 `selection` 双向同步。
///
/// 与 `TabView(.page)` 相比，松手时拖动超过页宽的 `swipeThreshold`（默认 20%），或快速甩动，就翻到相邻页；
/// 一次手势最多翻一页。各页在切换时保留，不重新创建。页内可放竖向 `List`、`ScrollView`，下拉刷新照常工作。
public struct SuitePager<Tag: Hashable, Page: View>: View {
    private let tags: [Tag]
    @Binding private var selection: Tag
    private let swipeThreshold: CGFloat
    private let page: (Tag) -> Page
    @State private var position: Tag?

    public init(
        tags: [Tag],
        selection: Binding<Tag>,
        swipeThreshold: CGFloat = SuitePagerMetrics.defaultSwipeThreshold,
        @ViewBuilder page: @escaping (Tag) -> Page
    ) {
        self.tags = tags
        self._selection = selection
        self.swipeThreshold = swipeThreshold
        self.page = page
        self._position = State(initialValue: selection.wrappedValue)
    }

    public var body: some View {
        // 按安全区内的尺寸给每页定宽高：页内列表据此留出导航栏与底部栏，不会被遮挡。
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(tags, id: \.self) { tag in
                        page(tag)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .id(tag)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(SuitePagingScrollTargetBehavior(swipeThreshold: swipeThreshold))
            .scrollPosition(id: $position)
            .onChange(of: position) { _, newValue in
                if let newValue, newValue != selection { selection = newValue }
            }
            .onChange(of: selection) { _, newValue in
                guard position != newValue else { return }
                withAnimation(.easeInOut(duration: 0.25)) { position = newValue }
            }
        }
    }
}

/// 按拖动比例翻页的横向分页规则：超过页宽的 `swipeThreshold` 或甩动的预计落点越过阈值即翻到相邻页，一次最多一页。
public struct SuitePagingScrollTargetBehavior: ScrollTargetBehavior {
    public var swipeThreshold: CGFloat

    public init(swipeThreshold: CGFloat = SuitePagerMetrics.defaultSwipeThreshold) {
        self.swipeThreshold = swipeThreshold
    }

    public func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        target.rect.origin.x = Self.pageOffset(
            start: context.originalTarget.rect.minX,
            proposed: target.rect.minX,
            pageWidth: context.containerSize.width,
            contentWidth: context.contentSize.width,
            swipeThreshold: swipeThreshold)
    }

    /// 由手势开始时的偏移与系统预计的落点（已含甩动惯性）求出应停靠的页面偏移。
    public static func pageOffset(
        start: CGFloat,
        proposed: CGFloat,
        pageWidth: CGFloat,
        contentWidth: CGFloat,
        swipeThreshold: CGFloat
    ) -> CGFloat {
        guard pageWidth > 0 else { return proposed }
        let pageCount = max(1, Int((contentWidth / pageWidth).rounded()))
        let startIndex = min(max(0, Int((start / pageWidth).rounded())), pageCount - 1)
        let distance = proposed - CGFloat(startIndex) * pageWidth
        let threshold = pageWidth * min(max(swipeThreshold, 0.01), 0.5)
        var index = startIndex
        if distance >= threshold {
            index += 1
        } else if distance <= -threshold {
            index -= 1
        }
        index = min(max(0, index), pageCount - 1)
        return CGFloat(index) * pageWidth
    }
}
#endif
