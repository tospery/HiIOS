import SwiftUI

/// 页面或内容区首次加载时的占位：只显示放大一档的加载动画，不显示文字。
///
/// `accessibilityLabel` 供 VoiceOver 朗读（例如“正在加载代码库”），由使用方提供并负责本地化。
/// 视图在可用空间内居中；放进列表或分组时按自身高度显示。
public struct SuitePageLoadingView: View {
    private let accessibilityLabel: String?

    public init(accessibilityLabel: String? = nil) {
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        indicator
            .controlSize(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder private var indicator: some View {
        if let accessibilityLabel {
            ProgressView().accessibilityLabel(accessibilityLabel)
        } else {
            ProgressView()
        }
    }
}
