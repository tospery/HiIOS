public enum DictionaryKeyMappingError: Error, Equatable, Sendable {
    case duplicateKey
}

public extension Dictionary {
    /// 重新映射键；不同原键映射到同一新键时抛错，避免静默覆盖数据。
    func remapKeys<MappedKey: Hashable>(
        _ transform: (Key) throws -> MappedKey
    ) throws -> [MappedKey: Value] {
        var result = [MappedKey: Value](minimumCapacity: count)
        for (key, value) in self {
            let mappedKey = try transform(key)
            guard result.updateValue(value, forKey: mappedKey) == nil else {
                throw DictionaryKeyMappingError.duplicateKey
            }
        }
        return result
    }
}
