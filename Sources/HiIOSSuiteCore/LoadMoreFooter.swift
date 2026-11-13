import SwiftUI

/// 列表分页尾的状态。
public enum LoadMoreState: Equatable, Sendable {
    /// 正在加载下一页。
    case loading
    /// 还有下一页，显示“加载更多”按钮。
    case more
    /// 已加载全部内容。
    case finished
    /// 加载失败；关联值为展示给用户的说明。
    case failed(String)

    /// 按“加载中 → 失败 → 还有下一页 → 已全部加载”的优先级得出状态。
    public init(isLoading: Bool, failure: String?, hasMore: Bool) {
        if isLoading {
            self = .loading
        } else if let failure {
            self = .failed(failure)
        } else if hasMore {
            self = .more
        } else {
            self = .finished
        }
    }
}

/// 分页尾的文案，由使用方提供并负责本地化。`finished` 为空时，全部加载完成后不显示结尾文字。
public struct LoadMoreLabels: Equatable, Sendable {
    public var loading: String
    public var loadMore: String
    public var finished: String?
    public var retry: String

    public init(loading: String, loadMore: String, finished: String? = nil, retry: String) {
        self.loading = loading
        self.loadMore = loadMore
        self.finished = finished
        self.retry = retry
    }
}

/// 列表底部的分页状态行：加载中、加载更多、已全部加载、失败重试。
///
/// 放在 `List` 末尾时自身不显示上下分隔线、使用透明行背景，和内容行区分开；放在其他容器中同样可用。
/// `accessibilityIdentifier` 为前缀，按钮分别标识为 `<前缀>.loadMore` 与 `<前缀>.retry`。
public struct LoadMoreFooter: View {
    private let state: LoadMoreState
    private let labels: LoadMoreLabels
    private let accessibilityIdentifier: String?
    private let onLoadMore: @MainActor () -> Void
    private let onRetry: @MainActor () -> Void

    /// - Parameters:
    ///   - onRetry: 失败后点击重试时执行；为空时与 `onLoadMore` 相同。
    public init(
        state: LoadMoreState,
        labels: LoadMoreLabels,
        accessibilityIdentifier: String? = nil,
        onLoadMore: @escaping @MainActor () -> Void,
        onRetry: (@MainActor () -> Void)? = nil
    ) {
        self.state = state
        self.labels = labels
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onLoadMore = onLoadMore
        self.onRetry = onRetry ?? onLoadMore
    }

    public var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView()
                    .accessibilityLabel(labels.loading)
            case .more:
                Button(labels.loadMore, action: onLoadMore)
                    .accessibilityIdentifier(identifier("loadMore"))
            case .finished:
                if let finished = labels.finished {
                    Text(finished)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            case .failed(let message):
                VStack(spacing: 8) {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button(labels.retry, action: onRetry)
                        .accessibilityIdentifier(identifier("retry"))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func identifier(_ suffix: String) -> String {
        accessibilityIdentifier.map { "\($0).\(suffix)" } ?? ""
    }
}
