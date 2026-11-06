import Foundation
import HiIOSBase

public enum ByteStoreError: String, ClassifiedFailure, Equatable {
    case temporarilyUnavailable
    case permissionDenied
    case invalidStoredData
    case invalidConfiguration
    case unexpected

    public var category: FailureCategory {
        FailureCategory(rawValue: rawValue) ?? .unexpected
    }
}

/// 存储键由调用方命名；adapter 决定实际隔离域与物理表示。
public struct StoreKey: Hashable, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) throws(ByteStoreError) {
        guard !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !rawValue.unicodeScalars.contains(where: { $0.value == 0 }) else {
            throw .invalidConfiguration
        }
        self.rawValue = rawValue
    }
}

/// 只定义字节读写，不隐含编码格式、同步策略或加密保证。
public protocol ByteStore: Sendable {
    func data(for key: StoreKey) async throws(ByteStoreError) -> Data?
    func set(_ data: Data, for key: StoreKey) async throws(ByteStoreError)
    // SwiftLint 0.55 将无返回值 typed throws 后的类型误判为变量名。
    // swiftlint:disable:next identifier_name
    func removeData(for key: StoreKey) async throws(ByteStoreError)
}
