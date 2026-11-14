import SwiftUI

/// 锚定气泡的位置计算，与视图分开以便测试。
///
/// 气泡优先显示在锚点上方，上方空间不足时显示在下方；水平方向以锚点为中心，并与容器左右至少保持 `margin`。
/// 箭头指向锚点中心，但不越过气泡圆角。
public enum SuiteAnchoredTooltipLayout {
    public static let arrowSize = CGSize(width: 16, height: 8)
    public static let cornerRadius: CGFloat = 14
    public static let margin: CGFloat = 8
    /// 箭头尖与锚点之间的间隙。
    public static let gap: CGFloat = 2

    public struct Placement: Equatable, Sendable {
        /// 气泡主体（不含箭头）在容器坐标中的位置。
        public let bubble: CGRect
        /// 箭头中心的横坐标（容器坐标）。
        public let arrowX: CGFloat
        /// 为真时气泡在锚点上方、箭头朝下。
        public let isAbove: Bool
    }

    /// - Parameters:
    ///   - anchor: 锚点在容器中的位置。
    ///   - bubbleSize: 气泡主体的尺寸。
    ///   - containerWidth: 容器宽度。
    ///   - spaceAbove: 锚点上沿之上可用于显示气泡的高度（已扣除导航栏等遮挡）。
    public static func placement(
        anchor: CGRect, bubbleSize: CGSize, containerWidth: CGFloat, spaceAbove: CGFloat
    ) -> Placement {
        let needed = bubbleSize.height + arrowSize.height + gap
        let isAbove = spaceAbove >= needed
        let maxX = max(margin, containerWidth - margin - bubbleSize.width)
        let originX = min(max(anchor.midX - bubbleSize.width / 2, margin), maxX)
        let originY = isAbove
            ? anchor.minY - gap - arrowSize.height - bubbleSize.height
            : anchor.maxY + gap + arrowSize.height
        let bubble = CGRect(origin: CGPoint(x: originX, y: originY), size: bubbleSize)
        let inset = cornerRadius + arrowSize.width / 2
        let lower = bubble.minX + inset
        let upper = bubble.maxX - inset
        let arrowX = lower <= upper ? min(max(anchor.midX, lower), upper) : bubble.midX
        return Placement(bubble: bubble, arrowX: arrowX, isAbove: isAbove)
    }
}

#if os(iOS)
public extension View {
    /// 在本视图上显示指向某个区域的气泡（深色底、浅色字，深色模式下反转），一段时间后渐隐消失。
    ///
    /// 气泡画在本视图的覆盖层中，可以超出本视图的边界；需要时给本视图更高的 `zIndex`，避免被后面的兄弟视图遮住。
    /// `text` 或 `anchor` 为空时不显示。点击气泡以外、滚动等关闭时机由使用方决定，关闭时把状态置空即可。
    ///
    /// - Parameters:
    ///   - text: 气泡文字，由使用方本地化。
    ///   - anchor: 被指向的区域，使用本视图的局部坐标。
    ///   - reservedTop: 屏幕顶部被导航栏等遮挡、不能放气泡的高度；上方剩余空间不足时气泡改到下方。
    ///   - autoDismissAfter: 显示多久后自动渐隐；文字或锚点变化时重新计时。为空时不自动消失。
    ///   - onDismiss: 自动消失时调用，使用方据此清空状态。
    func suiteAnchoredTooltip(
        text: String?,
        anchor: CGRect?,
        reservedTop: CGFloat = 100,
        autoDismissAfter: Duration? = .seconds(5),
        onDismiss: @escaping @MainActor () -> Void
    ) -> some View {
        modifier(SuiteAnchoredTooltipModifier(
            text: text, anchor: anchor, reservedTop: reservedTop,
            autoDismissAfter: autoDismissAfter, onDismiss: onDismiss))
    }
}

private struct SuiteAnchoredTooltipModifier: ViewModifier {
    let text: String?
    let anchor: CGRect?
    let reservedTop: CGFloat
    let autoDismissAfter: Duration?
    let onDismiss: @MainActor () -> Void

    @State private var containerWidth: CGFloat = 0
    @State private var containerMinY: CGFloat = 0
    @State private var bubbleSize: CGSize = .zero

    private struct Key: Equatable {
        let text: String
        let anchor: CGRect
    }

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                containerWidth = $0.width
                containerMinY = $0.minY
            }
            .overlay(alignment: .topLeading) {
                if let text, let anchor {
                    bubble(text: text, anchor: anchor)
                        .transition(.opacity)
                        .task(id: Key(text: text, anchor: anchor)) {
                            guard let autoDismissAfter else { return }
                            try? await Task.sleep(for: autoDismissAfter)
                            guard !Task.isCancelled else { return }
                            withAnimation(.easeOut(duration: 0.3)) { onDismiss() }
                        }
                }
            }
    }

    private func bubble(text: String, anchor: CGRect) -> some View {
        let placement = SuiteAnchoredTooltipLayout.placement(
            anchor: anchor, bubbleSize: bubbleSize, containerWidth: containerWidth,
            spaceAbove: containerMinY + anchor.minY - reservedTop)
        let arrow = SuiteAnchoredTooltipLayout.arrowSize
        return ZStack(alignment: .topLeading) {
            Text(text)
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(Color(uiColor: .systemBackground))
                .fixedSize()
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color(uiColor: .label), in: RoundedRectangle(
                    cornerRadius: SuiteAnchoredTooltipLayout.cornerRadius, style: .continuous))
                .onGeometryChange(for: CGSize.self) { $0.size } action: { bubbleSize = $0 }
                .offset(x: placement.bubble.minX, y: placement.bubble.minY)
            SuiteTooltipArrow(pointsDown: placement.isAbove)
                .fill(Color(uiColor: .label))
                .frame(width: arrow.width, height: arrow.height)
                .offset(
                    x: placement.arrowX - arrow.width / 2,
                    y: placement.isAbove ? placement.bubble.maxY : placement.bubble.minY - arrow.height)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.22), radius: 6, y: 3)
        .opacity(bubbleSize == .zero ? 0 : 1)
        .allowsHitTesting(false)
        .accessibilityElement()
        .accessibilityLabel(text)
    }
}

private struct SuiteTooltipArrow: Shape {
    let pointsDown: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if pointsDown {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        }
        path.closeSubpath()
        return path
    }
}
#endif
