import SwiftUI

#if os(iOS)
/// 主操作按钮：当前 `tint` 实心底、白色文字；禁用时系统灰底、次要文字色；按下时变淡。
///
/// 代替 `.borderedProminent`，保证任意主题色下文字都是白色，不随系统根据底色推断前景色。
/// 文字和加载动画（`ProgressView`）都使用白色。
public struct SuitePrimaryButtonStyle: ButtonStyle {
    /// 按钮外形。
    public enum Shape: Sendable {
        /// 圆角矩形，用于整行宽度的主按钮。
        case roundedRectangle
        /// 胶囊，用于行内或卡片中的紧凑按钮。
        case capsule
    }

    private let shape: Shape
    private let minHeight: CGFloat?

    /// - Parameters:
    ///   - shape: 按钮外形，默认圆角矩形。
    ///   - minHeight: 最小高度；为空时按文字高度加上下内边距。
    public init(shape: Shape = .roundedRectangle, minHeight: CGFloat? = nil) {
        self.shape = shape
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        SuitePrimaryButtonBody(configuration: configuration, shape: shape, minHeight: minHeight)
    }
}

private struct SuitePrimaryButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let shape: SuitePrimaryButtonStyle.Shape
    let minHeight: CGFloat?
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(isEnabled ? AnyShapeStyle(Color.white) : AnyShapeStyle(.secondary))
            .tint(isEnabled ? .white : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(minHeight: minHeight)
            .background { background }
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.75 : 1)
    }

    @ViewBuilder private var background: some View {
        switch shape {
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(fill)
        case .capsule:
            Capsule().fill(fill)
        }
    }

    private var fill: AnyShapeStyle {
        isEnabled ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(uiColor: .tertiarySystemFill))
    }
}

public extension ButtonStyle where Self == SuitePrimaryButtonStyle {
    /// 圆角矩形主按钮，见 ``SuitePrimaryButtonStyle``。
    static var suitePrimary: SuitePrimaryButtonStyle { SuitePrimaryButtonStyle() }

    /// 指定外形与最小高度的主按钮，见 ``SuitePrimaryButtonStyle``。
    static func suitePrimary(shape: SuitePrimaryButtonStyle.Shape, minHeight: CGFloat? = nil)
        -> SuitePrimaryButtonStyle {
        SuitePrimaryButtonStyle(shape: shape, minHeight: minHeight)
    }
}
#endif
