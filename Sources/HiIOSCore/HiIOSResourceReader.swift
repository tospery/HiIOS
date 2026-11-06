import Foundation
import HiIOSBase

public enum HiIOSResourceError: ClassifiedFailure, Equatable {
    case invalidName
    case missing
    case unreadable
    case invalidContent

    public var category: FailureCategory {
        switch self {
        case .invalidName: .invalidConfiguration
        case .missing, .unreadable: .temporarilyUnavailable
        case .invalidContent: .invalidStoredData
        }
    }
}

/// 调用方明确提供资源 Bundle，适用于 SPM 的 Bundle.module 和 CocoaPods 资源包。
public struct HiIOSResourceReader {
    private let bundle: Bundle

    public init(bundle: Bundle) {
        self.bundle = bundle
    }

    public func data(
        named name: String,
        withExtension fileExtension: String
    ) throws(HiIOSResourceError) -> Data {
        guard Self.validSegment(name), Self.validSegment(fileExtension) else { throw .invalidName }
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else { throw .missing }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw .unreadable
        }
    }

    public func decodeJSON<Value: Decodable>(
        _ type: Value.Type,
        named name: String,
        withExtension fileExtension: String = "json"
    ) throws(HiIOSResourceError) -> Value {
        let bytes = try data(named: name, withExtension: fileExtension)
        do {
            return try JSONDecoder().decode(type, from: bytes)
        } catch {
            throw .invalidContent
        }
    }

    private static func validSegment(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !value.contains("/")
            && !value.contains("\\")
            && !value.unicodeScalars.contains(where: { $0.value == 0 })
    }
}
