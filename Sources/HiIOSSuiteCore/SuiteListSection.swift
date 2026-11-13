import SwiftUI

/// 无业务的列表分组容器，承载一组 ``SuiteListRow`` 或 ``SuiteListButtonRow``。
///
/// 外观随 ``SuiteListStyle`` 变化：默认左右留白的圆角卡片，``SuiteListStyle/fullWidth`` 时与容器同宽、无圆角。
/// 分组之间、页面边距由页面布局决定；分组标题与脚注的文案由使用方提供并负责本地化。
public struct SuiteListSection<Content: View>: View {
    private let header: String?
    private let footer: String?
    private let cornerRadius: CGFloat
    private let content: Content
    @Environment(\.suiteListStyle) private var style

    public init(
        header: String? = nil,
        footer: String? = nil,
        cornerRadius: CGFloat = 14,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let header {
                Text(header)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, style.rowLeadingInset)
                    .accessibilityAddTraits(.isHeader)
            }
            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity)
            .background(Color.suiteContentSurface)
            .clipShape(RoundedRectangle(cornerRadius: style.sectionCornerRadius(cornerRadius), style: .continuous))
            if let footer {
                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, style.rowLeadingInset)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

extension Color {
    /// 行被按下时的高亮色。
    static var suiteRowHighlight: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemFill)
        #else
        Color.primary.opacity(0.1)
        #endif
    }
}
