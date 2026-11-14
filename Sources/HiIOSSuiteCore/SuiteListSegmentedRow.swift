import SwiftUI

/// ``SuiteListSegmentedRow`` 中的一个选项；标题由使用方提供并负责本地化。
public struct SuiteSegmentedOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: String

    public var id: Value { value }

    public init(value: Value, title: String) {
        self.value = value
        self.title = title
    }
}

extension SuiteSegmentedOption: Sendable where Value: Sendable {}
extension SuiteSegmentedOption: Equatable where Value: Equatable {}

/// ``SuiteListSegmentedRow`` 的尺寸约定。
public enum SuiteListSegmentedRowMetrics {
    /// 尾部分段选择器的默认宽度，与 Android 端同类行一致。
    public static let selectorWidth: CGFloat = 148
}

/// 左侧标题、右侧固定宽度分段选择器的列表行，用于“搜索类型”这类二三选一的设置项。
///
/// 行高、左右边距与分隔线和 ``SuiteListRow`` 一致；选项较长时系统分段控件会自动缩小字号。
public struct SuiteListSegmentedRow<Value: Hashable>: View {
    private let title: String
    private let options: [SuiteSegmentedOption<Value>]
    @Binding private var selection: Value
    private let selectorWidth: CGFloat
    private let showsDivider: Bool
    @Environment(\.suiteListStyle) private var style

    public init(
        title: String,
        options: [SuiteSegmentedOption<Value>],
        selection: Binding<Value>,
        selectorWidth: CGFloat = SuiteListSegmentedRowMetrics.selectorWidth,
        showsDivider: Bool = true
    ) {
        self.title = title
        self.options = options
        self._selection = selection
        self.selectorWidth = selectorWidth
        self.showsDivider = showsDivider
    }

    public var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .layoutPriority(1)
            Spacer(minLength: 0)
            Picker(title, selection: $selection) {
                ForEach(options) { option in
                    Text(option.title).tag(option.value)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: selectorWidth)
        }
        .padding(.vertical, 8)
        .padding(.trailing, style.rowTrailingInset)
        .frame(minHeight: SuiteListRowMetrics.minimumHeight)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Divider()
            }
        }
        .padding(.leading, style.rowLeadingInset)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
