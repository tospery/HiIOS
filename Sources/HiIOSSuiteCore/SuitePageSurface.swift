import SwiftUI

/// 页面画布与内容表面：浅灰画布上放白色内容（深色模式下分别为纯黑与深灰），两者始终有色差。
///
/// - 整页背景使用 ``SwiftUI/View/suitePageCanvas()``。
/// - `List` 使用 ``SwiftUI/View/suiteListCanvas()``，其中的内容行使用 ``SwiftUI/View/suiteListRowSurface()``；
///   空白区域露出画布，内容行保持白色。
/// - 阅读类页面的正文、评论等内容块使用 ``SwiftUI/View/suiteContentBlock(padding:)``，块与块之间露出画布作为间隔。
public extension Color {
    /// 页面画布色：浅色下为非常浅的灰色，深色下为纯黑。
    static var suitePageCanvas: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color.primary.opacity(0.03)
        #endif
    }

    /// 画布上的内容表面色：浅色下为白色，深色下为深灰。
    static var suiteContentSurface: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color.primary.opacity(0.04)
        #endif
    }
}

public extension View {
    /// 以页面画布色铺满背景（含安全区）。
    func suitePageCanvas() -> some View {
        background(Color.suitePageCanvas.ignoresSafeArea())
    }

    /// 让 `List` 使用无分组的平铺样式，并以页面画布色作为背景；内容行需另加 ``suiteListRowSurface()``。
    func suiteListCanvas() -> some View {
        listStyle(.plain)
            .scrollContentBackground(.hidden)
            .suitePageCanvas()
    }

    /// 将 `List` 中的一行设为内容表面色（白色）。
    func suiteListRowSurface() -> some View {
        listRowBackground(Color.suiteContentSurface)
    }

    /// 画布上的通栏内容块：四周留白、铺满宽度，以内容表面色为背景；块之间的间距由外层布局决定。
    func suiteContentBlock(padding: CGFloat = 16) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.suiteContentSurface)
    }
}
