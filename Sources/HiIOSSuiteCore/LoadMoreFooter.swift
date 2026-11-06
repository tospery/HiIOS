import SwiftUI

public enum LoadMoreState: Equatable, Sendable {
    case loading
    case finished
    case failed
}

/// 列表分页状态外壳；文案及重试行为由使用方提供。
public struct LoadMoreFooter: View {
    private let state: LoadMoreState
    private let loadingLabel: LocalizedStringKey
    private let finishedLabel: LocalizedStringKey
    private let errorLabel: LocalizedStringKey
    private let retryLabel: LocalizedStringKey
    private let onRetry: @MainActor () -> Void

    public init(
        state: LoadMoreState,
        loadingLabel: LocalizedStringKey,
        finishedLabel: LocalizedStringKey,
        errorLabel: LocalizedStringKey,
        retryLabel: LocalizedStringKey,
        onRetry: @escaping @MainActor () -> Void
    ) {
        self.state = state
        self.loadingLabel = loadingLabel
        self.finishedLabel = finishedLabel
        self.errorLabel = errorLabel
        self.retryLabel = retryLabel
        self.onRetry = onRetry
    }

    public var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView()
                    .accessibilityLabel(loadingLabel)
            case .finished:
                Text(finishedLabel)
                    .foregroundStyle(.secondary)
            case .failed:
                VStack {
                    Text(errorLabel)
                        .foregroundStyle(.secondary)
                    Button(retryLabel, action: onRetry)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}
