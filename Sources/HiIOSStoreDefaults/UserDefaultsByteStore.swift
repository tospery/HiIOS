import Foundation
import HiIOSStoreCore

/// 适合非敏感偏好字节；调用方以 suiteName 指定隔离域。
public actor UserDefaultsByteStore: ByteStore {
    private let defaults: UserDefaults
    private let namespace: String

    public init(
        suiteName: String? = nil,
        namespace: String
    ) throws(ByteStoreError) {
        guard !namespace.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw .invalidConfiguration
        }
        if let suiteName {
            guard !suiteName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let defaults = UserDefaults(suiteName: suiteName) else {
                throw .invalidConfiguration
            }
            self.defaults = defaults
        } else {
            self.defaults = .standard
        }
        self.namespace = namespace
    }

    public func data(for key: StoreKey) async throws(ByteStoreError) -> Data? {
        guard let value = defaults.object(forKey: qualified(key)) else { return nil }
        guard let data = value as? Data else { throw .invalidStoredData }
        return data
    }

    public func set(_ data: Data, for key: StoreKey) async throws(ByteStoreError) {
        defaults.set(data, forKey: qualified(key))
    }

    public func removeData(for key: StoreKey) async throws(ByteStoreError) {
        defaults.removeObject(forKey: qualified(key))
    }

    private func qualified(_ key: StoreKey) -> String {
        "\(namespace).\(key.rawValue)"
    }
}
