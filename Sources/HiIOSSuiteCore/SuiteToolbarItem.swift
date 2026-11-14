import SwiftUI

#if os(iOS)
public extension ToolbarContent {
    /// 传统导航栏的工具栏项：只显示图标或文字本身，不带 iOS 26 起的玻璃圆圈或胶囊背景。
    ///
    /// 导航栏上的每个 `ToolbarItem`、`ToolbarItemGroup` 都应使用它，避免各页面自行判断系统版本。
    @ToolbarContentBuilder
    func suitePlainToolbarItem() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}
#endif
