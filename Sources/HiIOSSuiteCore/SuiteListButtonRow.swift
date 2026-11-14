import SwiftUI

/// 标题居中的整行按钮，通常单独放在一个 ``SuiteListSection`` 中，用于“退出登录”“删除账号”等操作。
///
/// - 普通按钮使用当前 tint；`role` 为 `.destructive` 时使用红色。
/// - 被 `.disabled(_:)` 禁用时整行置灰且不可点击。
/// - 行高、左右边距与分隔线和 ``SuiteListRow`` 保持一致；标题文案由使用方提供并负责本地化。
public struct SuiteListButtonRow: View {
    private let title: String
    private let role: ButtonRole?
    private let showsDivider: Bool
    private let action: @MainActor () -> Void
    @Environment(\.suiteListStyle) private var style
    @Environment(\.isEnabled) private var isEnabled

    public init(
        title: String,
        role: ButtonRole? = nil,
        showsDivider: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.role = role
        self.showsDivider = showsDivider
        self.action = action
    }

    public var body: some View {
        Button(role: role, action: action) {
            Text(title)
                .font(.body)
                .foregroundStyle(titleStyle)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.vertical, 8)
                .padding(.horizontal, style.rowLeadingInset)
                .frame(maxWidth: .infinity, minHeight: SuiteListRowMetrics.minimumHeight)
                .overlay(alignment: .bottom) {
                    if showsDivider {
                        Divider()
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(SuiteListRowButtonStyle())
    }

    private var titleStyle: AnyShapeStyle {
        if !isEnabled {
            return AnyShapeStyle(.tertiary)
        }
        return role == .destructive ? AnyShapeStyle(Color.red) : AnyShapeStyle(.tint)
    }
}
