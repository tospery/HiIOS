import UIKit

public enum HiIOSFont {
    /// 使用指定文字样式的 Dynamic Type 比例缩放自定义系统字体。
    public static func scaledSystemFont(
        pointSize: CGFloat,
        weight: UIFont.Weight = .regular,
        textStyle: UIFont.TextStyle,
        compatibleWith traits: UITraitCollection? = nil
    ) -> UIFont {
        let base = UIFont.systemFont(ofSize: pointSize, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base, compatibleWith: traits)
    }
}
