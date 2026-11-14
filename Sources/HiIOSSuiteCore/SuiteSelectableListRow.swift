import SwiftUI

/// 单选列表行：外观与 ``SuiteListRow`` 一致，选中项在尾部显示 tint 色对勾，未选中时对勾位置留空，标题不跳动。
///
/// 通常放在 ``SuiteListSection`` 或 ``SuiteSearchableSelectionList`` 中；标题文案由使用方提供并负责本地化。
public struct SuiteSelectableListRow<Leading: View>: View {
    private let title: String
    private let supportingText: String?
    private let isSelected: Bool
    private let showsDivider: Bool
    private let action: @MainActor () -> Void
    private let leading: Leading

    public init(
        title: String,
        supportingText: String? = nil,
        isSelected: Bool,
        showsDivider: Bool = true,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.supportingText = supportingText
        self.isSelected = isSelected
        self.showsDivider = showsDivider
        self.action = action
        self.leading = leading()
    }

    public var body: some View {
        SuiteListRow(title: title, supportingText: supportingText, showsDivider: showsDivider, action: action) {
            leading
        } trailing: {
            Image(systemName: "checkmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(.tint)
                .opacity(isSelected ? 1 : 0)
                .accessibilityHidden(true)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

public extension SuiteSelectableListRow where Leading == EmptyView {
    init(
        title: String,
        supportingText: String? = nil,
        isSelected: Bool,
        showsDivider: Bool = true,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            title: title, supportingText: supportingText, isSelected: isSelected, showsDivider: showsDivider,
            action: action, leading: { EmptyView() })
    }
}
