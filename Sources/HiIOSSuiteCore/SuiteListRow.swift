import SwiftUI

/// 面向设置、资料等列表场景的无业务通用行，通常放在 ``SuiteListSection`` 中。
///
/// - `trailingText` 适合“标题 + 右侧值 + 箭头”：标题优先完整显示，右侧值先缩小字号，仍放不下再截断。
/// - `leading` 放图标等前置视图；`trailing` 放开关等自定义尾部视图，位于右侧值与箭头之间。
/// - `action` 为空时行不可点击、无按压态；`isDimmed` 用于“未设置”等弱化展示。
/// - 分隔线从标题起始处开始，与前置视图不重叠。
///
/// 所有文案由使用方提供并负责本地化。
public struct SuiteListRow<Leading: View, Trailing: View>: View {
    private let title: String
    private let supportingText: String?
    private let trailingText: String?
    private let showsChevron: Bool
    private let isDimmed: Bool
    private let showsDivider: Bool
    private let action: (@MainActor () -> Void)?
    private let leading: Leading
    private let trailing: Trailing

    public init(
        title: String,
        supportingText: String? = nil,
        trailingText: String? = nil,
        showsChevron: Bool = false,
        isDimmed: Bool = false,
        showsDivider: Bool = true,
        action: (@MainActor () -> Void)? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.supportingText = supportingText
        self.trailingText = trailingText
        self.showsChevron = showsChevron
        self.isDimmed = isDimmed
        self.showsDivider = showsDivider
        self.action = action
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(SuiteListRowButtonStyle())
        } else {
            content
                .accessibilityElement(children: .combine)
        }
    }

    private var content: some View {
        HStack(spacing: 12) {
            leading
                .opacity(isDimmed ? 0.55 : 1)
            HStack(spacing: 8) {
                titleColumn
                    .layoutPriority(1)
                Spacer(minLength: 0)
                if let trailingText {
                    Text(trailingText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.trailing)
                }
                trailing
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 8)
            .padding(.trailing, 16)
            .frame(minHeight: 48)
            .overlay(alignment: .bottom) {
                if showsDivider {
                    Divider()
                }
            }
        }
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var titleColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.body)
                .foregroundStyle(isDimmed ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary))
                .lineLimit(1)
            if let supportingText {
                Text(supportingText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

public extension SuiteListRow where Leading == EmptyView, Trailing == EmptyView {
    init(
        title: String,
        supportingText: String? = nil,
        trailingText: String? = nil,
        showsChevron: Bool = false,
        isDimmed: Bool = false,
        showsDivider: Bool = true,
        action: (@MainActor () -> Void)? = nil
    ) {
        self.init(
            title: title, supportingText: supportingText, trailingText: trailingText,
            showsChevron: showsChevron, isDimmed: isDimmed, showsDivider: showsDivider, action: action,
            leading: { EmptyView() }, trailing: { EmptyView() })
    }
}

public extension SuiteListRow where Trailing == EmptyView {
    init(
        title: String,
        supportingText: String? = nil,
        trailingText: String? = nil,
        showsChevron: Bool = false,
        isDimmed: Bool = false,
        showsDivider: Bool = true,
        action: (@MainActor () -> Void)? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            title: title, supportingText: supportingText, trailingText: trailingText,
            showsChevron: showsChevron, isDimmed: isDimmed, showsDivider: showsDivider, action: action,
            leading: leading, trailing: { EmptyView() })
    }
}

/// 按下时整行高亮，不改变文字颜色。
private struct SuiteListRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(configuration.isPressed ? Color.suiteRowHighlight : Color.clear)
    }
}
