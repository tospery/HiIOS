import Foundation
import HiIOSNavCore
import UIKit

#if canImport(URLNavigator_Hi)
import URLNavigator_Hi
#elseif canImport(URLNavigator)
import URLNavigator
#endif

public enum URLNavigationError: Error, Equatable, Sendable {
    case disallowedURL
    case unhandledURL
}

/// URLNavigator 的可选 UIKit 适配器；外部 URL 必须先匹配调用方的允许列表。
@MainActor
public final class RxURLNavigator {
    private let navigator = Navigator()

    public init() {}

    public func register(
        _ pattern: String,
        makeViewController: @escaping @MainActor (URL) -> UIViewController?
    ) {
        navigator.register(pattern) { convertible, _, _ in
            guard let url = convertible.urlValue, Thread.isMainThread else { return nil }
            return MainActor.assumeIsolated {
                makeViewController(url)
            }
        }
    }

    public func open(
        _ url: URL,
        allowedBy patterns: [HiIOSNavCore.URLPattern],
        queryIsAllowed: (URL) -> Bool
    ) throws(URLNavigationError) -> Bool {
        guard patterns.contains(where: { $0.matches(url) }), queryIsAllowed(url) else {
            throw .disallowedURL
        }
        guard navigator.open(url) else {
            throw .unhandledURL
        }
        return true
    }

    public func push(
        _ url: URL,
        from navigationController: UINavigationController,
        allowedBy patterns: [HiIOSNavCore.URLPattern],
        queryIsAllowed: (URL) -> Bool
    ) throws(URLNavigationError) -> UIViewController {
        guard patterns.contains(where: { $0.matches(url) }), queryIsAllowed(url) else {
            throw .disallowedURL
        }
        guard let destination = navigator.push(url, from: navigationController) else {
            throw .unhandledURL
        }
        return destination
    }
}
