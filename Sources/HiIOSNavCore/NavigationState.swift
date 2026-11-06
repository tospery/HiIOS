import Foundation

/// 路由值由项目定义；导航库只描述动作，不持有业务状态或全局窗口。
public enum NavigationAction<Route: Hashable & Sendable>: Hashable, Sendable {
    case push(Route)
    case present(Route)
    case replaceRoot(Route)
    case pop
    case dismiss
}

/// 项目可用 SwiftUI 状态、UIKit coordinator 或其他实现处理同一导航动作。
public protocol NavigationHandling: Sendable {
    associatedtype Route: Hashable & Sendable
    func handle(_ action: NavigationAction<Route>) async
}

public enum ToastStyle: String, CaseIterable, Sendable {
    case information
    case success
    case warning
    case error
}

public struct ToastState: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let message: String
    public let style: ToastStyle
    public let duration: Duration?

    public init(
        id: UUID = UUID(),
        message: String,
        style: ToastStyle = .information,
        duration: Duration? = .seconds(3)
    ) {
        self.id = id
        self.message = message
        self.style = style
        self.duration = duration
    }
}

public enum PresentationActionRole: String, CaseIterable, Sendable {
    case `default`
    case cancel
    case destructive
}

/// 文案与动作 ID 均由调用方提供，便于业务本地化和测试。
public struct PresentationAction: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let role: PresentationActionRole

    public init(id: String, title: String, role: PresentationActionRole = .default) {
        self.id = id
        self.title = title
        self.role = role
    }
}

public struct AlertState: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let message: String?
    public let actions: [PresentationAction]

    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        actions: [PresentationAction]
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.actions = actions
    }
}

public struct DialogState: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let message: String?
    public let actions: [PresentationAction]

    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        actions: [PresentationAction]
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.actions = actions
    }
}

/// 弹层载荷使用调用方定义的强类型，避免旧实现中的任意字典与字符串类型码。
public struct PopupState<Payload: Hashable & Sendable>: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let payload: Payload

    public init(id: UUID = UUID(), payload: Payload) {
        self.id = id
        self.payload = payload
    }
}
