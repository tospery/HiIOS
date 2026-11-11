import SwiftUI

/// ``SuiteListSection`` 与其中各行的外观样式，通过 ``SwiftUI/View/suiteListStyle(_:)`` 自上而下传递。
///
/// - ``insetGrouped``：左右留白的圆角卡片分组，行左边距 16。
/// - ``fullWidth``：与容器同宽、无圆角的通栏分组，行左边距 20；分隔线从标题起始处延伸到容器右边缘。
///
/// 通栏样式下，分组之间的间距与页面背景色（通常为系统分组背景）由页面布局决定。
public enum SuiteListStyle: Sendable, Equatable {
    case insetGrouped
    case fullWidth

    /// 行内容（前置视图或标题）距离行左边缘的间距。
    var rowLeadingInset: CGFloat {
        switch self {
        case .insetGrouped: 16
        case .fullWidth: 20
        }
    }

    /// 行内容距离行右边缘的间距。
    var rowTrailingInset: CGFloat {
        switch self {
        case .insetGrouped: 16
        case .fullWidth: 20
        }
    }

    /// 分组容器的圆角；通栏样式不使用圆角。
    func sectionCornerRadius(_ requested: CGFloat) -> CGFloat {
        switch self {
        case .insetGrouped: requested
        case .fullWidth: 0
        }
    }
}

private struct SuiteListStyleKey: EnvironmentKey {
    static let defaultValue: SuiteListStyle = .insetGrouped
}

extension EnvironmentValues {
    /// 当前生效的列表样式，默认 ``SuiteListStyle/insetGrouped``。
    public var suiteListStyle: SuiteListStyle {
        get { self[SuiteListStyleKey.self] }
        set { self[SuiteListStyleKey.self] = newValue }
    }
}

extension View {
    /// 为当前视图树中的 ``SuiteListSection`` 与 ``SuiteListRow`` 指定外观样式。
    public func suiteListStyle(_ style: SuiteListStyle) -> some View {
        environment(\.suiteListStyle, style)
    }
}
