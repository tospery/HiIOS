import SwiftUI

#if os(iOS)
/// ``SuiteSearchableSelectionList`` 中的一个选项。
///
/// `keywords` 是标题以外也参与搜索的文字（如语言代码）；标题与关键字由使用方提供并负责本地化。
public struct SuiteSelectionOption<ID: Hashable>: Identifiable {
    public let id: ID
    public let title: String
    public let keywords: [String]
    public let accessibilityIdentifier: String?

    public init(id: ID, title: String, keywords: [String] = [], accessibilityIdentifier: String? = nil) {
        self.id = id
        self.title = title
        self.keywords = keywords
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    /// 标题或任一关键字包含去掉首尾空白后的搜索词（不区分大小写）；搜索词为空时总是匹配。
    public func matches(_ query: String) -> Bool {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return true }
        return title.localizedCaseInsensitiveContains(term)
            || keywords.contains { $0.localizedCaseInsensitiveContains(term) }
    }
}

extension SuiteSelectionOption: Sendable where ID: Sendable {}
extension SuiteSelectionOption: Equatable where ID: Equatable {}

/// ``SuiteSearchableSelectionList`` 的文案，由使用方提供并负责本地化。
public struct SuiteSearchableSelectionLabels: Sendable {
    public let searchPrompt: String
    public let clearSearch: String
    public let noResults: String
    /// 不为空时在列表顶部显示“不限”项，选中它表示 `selection` 为 `nil`；只在未输入搜索词时显示。
    public let anyOption: String?

    public init(searchPrompt: String, clearSearch: String, noResults: String, anyOption: String? = nil) {
        self.searchPrompt = searchPrompt
        self.clearSearch = clearSearch
        self.noResults = noResults
        self.anyOption = anyOption
    }
}

/// 顶部常驻搜索框（``SuiteSearchField``）加通栏单选列表的整页内容，用于语言等长列表的单选。
///
/// 搜索词由本视图自己保存，输入即过滤；列表惰性加载，滚动时收起键盘；没有匹配项时显示空态。
/// 每行是 ``SuiteSelectableListRow``，与屏幕同宽。选中后调用 `onSelect`，是否返回上一页由使用方决定。
public struct SuiteSearchableSelectionList<ID: Hashable, Leading: View>: View {
    private let options: [SuiteSelectionOption<ID>]
    private let selection: ID?
    private let labels: SuiteSearchableSelectionLabels
    private let anyAccessibilityIdentifier: String?
    private let onSelect: @MainActor (ID?) -> Void
    private let leading: (SuiteSelectionOption<ID>) -> Leading
    @State private var query = ""

    public init(
        options: [SuiteSelectionOption<ID>],
        selection: ID?,
        labels: SuiteSearchableSelectionLabels,
        anyAccessibilityIdentifier: String? = nil,
        onSelect: @escaping @MainActor (ID?) -> Void,
        @ViewBuilder leading: @escaping (SuiteSelectionOption<ID>) -> Leading
    ) {
        self.options = options
        self.selection = selection
        self.labels = labels
        self.anyAccessibilityIdentifier = anyAccessibilityIdentifier
        self.onSelect = onSelect
        self.leading = leading
    }

    public var body: some View {
        let visible = options.filter { $0.matches(query) }
        let showsAny = labels.anyOption != nil && query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        VStack(spacing: 0) {
            SuiteSearchField(text: $query, prompt: labels.searchPrompt, clearAccessibilityLabel: labels.clearSearch)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .accessibilityIdentifier("suite.selection.search")
            if visible.isEmpty && !showsAny {
                ContentUnavailableView(labels.noResults, systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if showsAny, let anyTitle = labels.anyOption {
                            SuiteSelectableListRow(
                                title: anyTitle, isSelected: selection == nil, showsDivider: !visible.isEmpty,
                                action: { onSelect(nil) }
                            )
                            .modifier(SuiteOptionalIdentifier(identifier: anyAccessibilityIdentifier))
                        }
                        ForEach(visible) { option in
                            SuiteSelectableListRow(
                                title: option.title, isSelected: selection == option.id,
                                showsDivider: option.id != visible.last?.id,
                                action: { onSelect(option.id) }
                            ) {
                                leading(option)
                            }
                            .modifier(SuiteOptionalIdentifier(identifier: option.accessibilityIdentifier))
                        }
                    }
                    .background(Color.suiteContentSurface)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .suitePageCanvas()
        .suiteListStyle(.fullWidth)
    }
}

public extension SuiteSearchableSelectionList where Leading == EmptyView {
    init(
        options: [SuiteSelectionOption<ID>],
        selection: ID?,
        labels: SuiteSearchableSelectionLabels,
        anyAccessibilityIdentifier: String? = nil,
        onSelect: @escaping @MainActor (ID?) -> Void
    ) {
        self.init(
            options: options, selection: selection, labels: labels,
            anyAccessibilityIdentifier: anyAccessibilityIdentifier, onSelect: onSelect,
            leading: { _ in EmptyView() })
    }
}

private struct SuiteOptionalIdentifier: ViewModifier {
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
