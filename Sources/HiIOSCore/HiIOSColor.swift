import UIKit

/// 明确使用 RRGGBB 或 RRGGBBAA 顺序，避免与 ARGB 混淆。
public enum HiIOSColor {
    public static func uiColor(rgbaHex input: String) -> UIColor? {
        let hex = input.hasPrefix("#") ? String(input.dropFirst()) : input
        guard hex.count == 6 || hex.count == 8,
              hex.unicodeScalars.allSatisfy({ CharacterSet(charactersIn: "0123456789ABCDEFabcdef").contains($0) }),
              let value = UInt64(hex, radix: 16) else { return nil }

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64
        if hex.count == 6 {
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
            alpha = 0xFF
        } else {
            red = (value >> 24) & 0xFF
            green = (value >> 16) & 0xFF
            blue = (value >> 8) & 0xFF
            alpha = value & 0xFF
        }
        return UIColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }

    public static func rgbaHex(of color: UIColor) -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        let channels = [red, green, blue, alpha].map { Int(($0 * 255).rounded().clamped(to: 0...255)) }
        return String(format: "#%02X%02X%02X%02X", channels[0], channels[1], channels[2], channels[3])
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
