import SwiftUI

/// 页面或内容区首次加载时的占位：只显示放大一档的加载动画，不显示文字。
///
/// 动画使用当前 `tint`（通常是 App 主色），所有页面的首屏加载因此保持同一颜色。
/// `accessibilityLabel` 供 VoiceOver 朗读（例如“正在加载代码库”），由使用方提供并负责本地化。
/// 视图在可用空间内居中；放进列表或分组时按自身高度显示。
public struct SuitePageLoadingView: View {
    private let accessibilityLabel: String?

    public init(accessibilityLabel: String? = nil) {
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        SuiteActivityIndicator()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement()
            .accessibilityLabel(accessibilityLabel ?? "")
            .accessibilityAddTraits(.updatesFrequently)
    }
}

/// 与系统大号加载指示器同尺寸的八辐条转圈动画，颜色取当前 `tint`。
///
/// 系统 `ProgressView` 的转圈固定为灰色、无法跟随环境 tint，因此自行绘制。
public struct SuiteActivityIndicator: View {
    private let diameter: CGFloat

    public init(diameter: CGFloat = 37) {
        self.diameter = diameter
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 8)) { context in
            let step = Int((context.date.timeIntervalSinceReferenceDate * 8).rounded(.down)) % 8
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Capsule()
                        .fill(.tint)
                        .frame(width: diameter * 0.095, height: diameter * 0.26)
                        .offset(y: -diameter * 0.32)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .opacity(Self.spokeOpacity(spoke: index, head: step))
                }
            }
            .frame(width: diameter, height: diameter)
        }
        .accessibilityHidden(true)
    }

    /// 当前领头的辐条最深，按转动方向向后逐渐变淡。
    public nonisolated static func spokeOpacity(spoke: Int, head: Int) -> Double {
        let distance = (head - spoke + 8) % 8
        return max(0.2, 1 - Double(distance) * 0.12)
    }
}
