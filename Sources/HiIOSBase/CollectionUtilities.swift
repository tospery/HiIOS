public extension Collection {
    /// 以集合起点为零偏移安全读取，适用于 ArraySlice 等非零 startIndex 的集合。
    func element(atOffset offset: Int) -> Element? {
        guard offset >= 0,
              let index = index(startIndex, offsetBy: offset, limitedBy: endIndex),
              index != endIndex else {
            return nil
        }
        return self[index]
    }
}
