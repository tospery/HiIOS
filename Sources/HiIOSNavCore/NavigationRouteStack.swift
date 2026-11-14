import Foundation

/// 一个导航栈的强类型路由序列，供 SwiftUI `NavigationStack(path:)` 或 swift-navigation 等状态驱动导航绑定。
///
/// 所有写入都返回出栈的路由（旧序列中公共前缀之后的部分），调用方据此释放页面独占的资源。
public struct NavigationRouteStack<Route: Hashable>: Hashable {
    public private(set) var routes: [Route]

    public init(_ routes: [Route] = []) {
        self.routes = routes
    }

    public var isEmpty: Bool { routes.isEmpty }
    public var count: Int { routes.count }
    public var last: Route? { routes.last }

    public mutating func push(_ route: Route) {
        routes.append(route)
    }

    /// 整体替换（返回、右滑、系统写回路径都经过这里）；返回被移出的路由。
    @discardableResult
    public mutating func setRoutes(_ newRoutes: [Route]) -> [Route] {
        let common = zip(routes, newRoutes).prefix { $0 == $1 }.count
        let removed = Array(routes[common...])
        routes = newRoutes
        return removed
    }

    @discardableResult
    public mutating func pop(count: Int = 1) -> [Route] {
        setRoutes(Array(routes.dropLast(min(max(0, count), routes.count))))
    }

    @discardableResult
    public mutating func popToRoot() -> [Route] {
        setRoutes([])
    }

    /// 移除最后一次出现的 `route` 及压在它上面的路由；栈中没有它时不变。
    @discardableResult
    public mutating func pop(through route: Route) -> [Route] {
        guard let index = routes.lastIndex(of: route) else { return [] }
        return setRoutes(Array(routes[..<index]))
    }
}

extension NavigationRouteStack: Sendable where Route: Sendable {}
