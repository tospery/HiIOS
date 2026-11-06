import Foundation

public extension StringProtocol {
    /// 只解析明确的布尔字面值；未知值不会被猜测为 false。
    var parsedBoolean: Bool? {
        let token = String(self).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch token {
        case "true", "yes", "1": return true
        case "false", "no", "0": return false
        default: return nil
        }
    }
}

public extension Double {
    /// 按指定规则取整后转换为 Int；非有限值与越界值返回 nil。
    func roundedInt(
        roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero
    ) -> Int? {
        guard isFinite else { return nil }
        return Int(exactly: rounded(roundingRule))
    }
}
