//
//  Constant.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit
import DeviceKit

// MARK: - 编译常量
/// 判断当前是否debug编译模式
public var isDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}

// MARK: - 设备常量
/// 设备类型
public var isPad: Bool { Device.current.isPad }
public var isPod: Bool { Device.current.isPod }
public var isPhone: Bool { Device.current.isPhone }
public var isSimulator: Bool { Device.current.isSimulator }
/// 操作系统版本号，只获取第二级的版本号，例如 10.3.1 只会得到 10.3
public var iOSVersion: Double { (UIDevice.current.systemVersion as NSString).doubleValue }
/// 是否横竖屏，用户界面横屏了才会返回YES
public var isLandscape: Bool { UIApplication.shared.windows.first!.windowScene!.interfaceOrientation.isLandscape }
/// 无论支不支持横屏，只要设备横屏了，就会返回YES
public var isDeviceLandscape: Bool { UIDevice.current.orientation.isLandscape }
/// 屏幕宽度，会根据横竖屏的变化而变化
public var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
/// 屏幕高度，会根据横竖屏的变化而变化
public var screenHeight: CGFloat { UIScreen.main.bounds.size.height }
/// 设备宽度，跟横竖屏无关
public var deviceWidth: CGFloat { min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) }
/// 设备高度，跟横竖屏无关
public var deviceHeight: CGFloat { max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) }

/// 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
/// @NEW_DEVICE_CHECKER
public var isNotchedScreen: Bool { Device.current.hasSensorHousing }

/// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕（也即大屏幕）。
/// @note 注意，这里普通/紧凑的标准是 QMUI 自行制定的，与系统 UITraitCollection.horizontalSizeClass/verticalSizeClass 的值无关。只要是通常意义上的“大屏幕手机”（例如 Plus 系列）都会被视为 Regular Screen。
/// @NEW_DEVICE_CHECKER
public var isRegularScreen: Bool {
    if isPad {
        return true
    }
    if isZoomMode {
        return false
    }
    let diagonal = Device.current.diagonal
    return diagonal == 6.7 || diagonal == 6.5 || diagonal == 6.1 || diagonal == 5.5
}

/// 是否Retina
public var isRetinaScreen: Bool { UIScreen.main.scale >= 2.0 }
/// HiIOS自定义的iPhone屏幕大小分类，以设备宽度为基准。
public var isSmallScreen: Bool { deviceWidth <= 320 }
public var isMiddleScreen: Bool { deviceWidth > 320 && deviceWidth < 414 }
public var isLargeScreen: Bool { deviceWidth >= 414 }
/// 是否放大模式（iPhone 6及以上的设备支持放大模式，iPhone X 除外）
public var isZoomMode: Bool { Device.current.isZoomed ?? false }

// MARK: - 布局常量
/// 获取一个像素
public var pixelOne: CGFloat {
    if pixelOneValue < 0 {
        pixelOneValue = 1.0 / UIScreen.main.scale
    }
    return pixelOneValue
}
private var pixelOneValue = -1.f

/// 当前已有的宽度有：320 | 360 | 375 | 390 | 393 | 414 | 428 | 430，参考https://note.youdao.com/s/cdwYQ7HQ
public var designWidth: CGFloat { 390.0 }
/// bounds && nativeBounds / scale && nativeScale
public var screenBoundsSize: CGSize { UIScreen.main.bounds.size }
public var screenNativeBoundsSize: CGSize { UIScreen.main.nativeBounds.size }
public var screenScale: CGFloat { UIScreen.main.scale }
public var screenNativeScale: CGFloat { UIScreen.main.nativeScale }

/// 状态栏高度(来电等情况下，状态栏高度会发生变化，所以应该实时计算，iOS 13 起，来电等情况下状态栏高度不会改变)
public var statusBarHeight: CGFloat {
    (UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.size.height)
}

/// 状态栏高度(如果状态栏不可见，也会返回一个普通状态下可见的高度)
/// @NEW_DEVICE_CHECKER
public var statusBarHeightConstant: CGFloat {
    let deviceModel = UIDevice.current.modelName
    if !UIApplication.shared.isStatusBarHidden {
#if IOS16_SDK_ALLOWED
#else
        // Xcode 14 SDK 编译的才能在 iPhone 14 Pro 上读取到正确的值，否则会读到 iPhone 13 Pro 的值，过渡期间做个兼容
        if !isLandscape && (deviceModel == "iPhone15,2" || deviceModel == "iPhone15,3") {
            return 54
        }
#endif
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    if isPad {
        return isNotchedScreen ? 24 : 20
    }
    if !isNotchedScreen {
        return 20
    }
    if isLandscape {
        return 0
    }
    if deviceModel == "iPhone12,1" {
        return 48
    }
    if deviceModel == "iPhone15,2" || deviceModel == "iPhone15,3" {
        return 54
    }
    let diagonal = Device.current.diagonal
    if (diagonal == 6.1 && (deviceWidth == 390 && deviceHeight == 844)) || diagonal == 6.7 {
        return 47
    }
    return (diagonal == 5.4 && iOSVersion >= 15.0) ? 50 : 44
}

/// navigationBar的静态高度
/// @NEW_DEVICE_CHECKER
public var navigationBarHeight: CGFloat {
    (isPad ? 50 : (isLandscape ? preferredValue(regular: 44, compact: 32) : 44))
}

/// 代表(导航栏+状态栏)，这里用于获取其高度
/// @warn 如果是用于 viewController，请使用 UIViewController(Frame) hi_navigationBarMaxYInViewCoordinator 代替
public var navigationContentTop: CGFloat {
    statusBarHeight + navigationBarHeight
}

/// 同上，这里用于获取它的静态常量值
public var navigationContentTopConstant: CGFloat {
    statusBarHeightConstant + navigationBarHeight
}

/// tabBar的高度
public var tabBarHeight: CGFloat {
    (isPad ? (isNotchedScreen ? 65 : 50) : (isLandscape ? preferredValue(regular: 49, compact: 32) : 49) + safeArea.bottom)
}

/// toolBar的高度
public var toolBarHeight: CGFloat {
    (isPad ? (isNotchedScreen ? 70 : 50) : (isLandscape ? preferredValue(regular: 44, compact: 32) : 44) + safeArea.bottom)
}

/// 安全区域
/// 用于获取 isNotchedScreen 设备的 insets，注意对于无 Home 键的新款 iPad 而言，它不一定有物理凹槽，但因为使用了 Home Indicator，所以它的 safeAreaInsets 也是非0。
/// @NEW_DEVICE_CHECKER
public var safeArea: UIEdgeInsets {
    if !isNotchedScreen {
        return .zero
    }
    
    if isPad {
        return .init(top: 24, left: 0, bottom: 20, right: 0)
    }
    
    if safeAreaInfo == nil {
        safeAreaInfo = [
            // iPhone 14
            "iPhone14,7": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone14,7-Zoom": [
                .portrait: .init(top: 48, left: 0, bottom: 28, right: 0),
                .landscapeLeft: .init(top: 0, left: 48, bottom: 21, right: 48)
            ],
            // iPhone 14 Plus
            "iPhone14,8": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone14,8-Zoom": [
                .portrait: .init(top: 41, left: 0, bottom: 30, right: 0),
                .landscapeLeft: .init(top: 0, left: 41, bottom: 21, right: 41)
            ],
            // iPhone 14 Pro
            "iPhone15,2": [
                .portrait: .init(top: 59, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 59, bottom: 21, right: 59)
            ],
            "iPhone15,2-Zoom": [
                .portrait: .init(top: 48, left: 0, bottom: 28, right: 0),
                .landscapeLeft: .init(top: 0, left: 48, bottom: 21, right: 48)
            ],
            // iPhone 14 Pro Max
            "iPhone15,3": [
                .portrait: .init(top: 59, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 59, bottom: 21, right: 59)
            ],
            "iPhone15,3-Zoom": [
                .portrait: .init(top: 51, left: 0, bottom: 31, right: 0),
                .landscapeLeft: .init(top: 0, left: 51, bottom: 21, right: 51)
            ],
            // iPhone 13 mini
            "iPhone14,4": [
                .portrait: .init(top: 50, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 50, bottom: 21, right: 50)
            ],
            "iPhone14,4-Zoom": [
                .portrait: .init(top: 43, left: 0, bottom: 29, right: 0),
                .landscapeLeft: .init(top: 0, left: 43, bottom: 21, right: 43)
            ],
            // iPhone 13
            "iPhone14,5": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone14,5-Zoom": [
                .portrait: .init(top: 39, left: 0, bottom: 28, right: 0),
                .landscapeLeft: .init(top: 0, left: 39, bottom: 21, right: 39)
            ],
            // iPhone 13 Pro
            "iPhone14,2": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone14,2-Zoom": [
                .portrait: .init(top: 39, left: 0, bottom: 28, right: 0),
                .landscapeLeft: .init(top: 0, left: 39, bottom: 21, right: 39)
            ],
            // iPhone 13 Pro Max
            "iPhone14,3": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone14,3-Zoom": [
                .portrait: .init(top: 41, left: 0, bottom: 29 + 2.0 / 3.0, right: 0),
                .landscapeLeft: .init(top: 0, left: 41, bottom: 21, right: 41)
            ],
            // iPhone 12 mini
            "iPhone13,1": [
                .portrait: .init(top: 50, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 50, bottom: 21, right: 50)
            ],
            "iPhone13,1-Zoom": [
                .portrait: .init(top: 43, left: 0, bottom: 29, right: 0),
                .landscapeLeft: .init(top: 0, left: 43, bottom: 21, right: 43)
            ],
            // iPhone 12
            "iPhone13,2": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone13,2-Zoom": [
                .portrait: .init(top: 39, left: 0, bottom: 28, right: 0),
                .landscapeLeft: .init(top: 0, left: 39, bottom: 21, right: 39)
            ],
            // iPhone 12 Pro
            "iPhone13,3": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone13,3-Zoom": [
                .portrait: .init(top: 39, left: 0, bottom: 28, right: 0),
                .landscapeLeft: .init(top: 0, left: 39, bottom: 21, right: 39)
            ],
            // iPhone 12 Pro Max
            "iPhone13,4": [
                .portrait: .init(top: 47, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 47, bottom: 21, right: 47)
            ],
            "iPhone13,4-Zoom": [
                .portrait: .init(top: 41, left: 0, bottom: 29 + 2.0 / 3.0, right: 0),
                .landscapeLeft: .init(top: 0, left: 41, bottom: 21, right: 41)
            ],
            // iPhone 11
            "iPhone12,1": [
                .portrait: .init(top: 48, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 48, bottom: 21, right: 48)
            ],
            "iPhone12,1-Zoom": [
                .portrait: .init(top: 44, left: 0, bottom: 31, right: 0),
                .landscapeLeft: .init(top: 0, left: 44, bottom: 21, right: 44)
            ],
            // iPhone 11 Pro Max
            "iPhone12,5": [
                .portrait: .init(top: 44, left: 0, bottom: 34, right: 0),
                .landscapeLeft: .init(top: 0, left: 44, bottom: 21, right: 44)
            ],
            "iPhone12,5-Zoom": [
                .portrait: .init(top: 40, left: 0, bottom: 30 + 2.0 / 3.0, right: 0),
                .landscapeLeft: .init(top: 0, left: 40, bottom: 21, right: 40)
            ]
        ]
    }
    
    var deviceKey = Device.identifier
    if safeAreaInfo?[deviceKey] == nil {
        deviceKey = "iPhone15,2" // 默认按最新的机型处理，因为新出的设备肯定更大概率与上一代设备相似
    }
    if isZoomMode {
        deviceKey += "-Zoom"
    }
    
    var orientationKey: UIInterfaceOrientation = .portrait
    let orientation = UIApplication.shared.statusBarOrientation
    switch orientation {
    case .landscapeLeft, .landscapeRight:
        orientationKey = .landscapeLeft
    default:
        break
    }
    
    var insets = safeAreaInfo![deviceKey]![orientationKey]!
    if orientation == .portraitUpsideDown {
        insets = .init(top: insets.bottom, left: insets.left, bottom: insets.top, right: insets.right)
    } else if orientation == .landscapeRight {
        insets = .init(top: insets.top, left: insets.right, bottom: insets.bottom, right: insets.left)
    }
    return insets
}
private var safeAreaInfo: [String : [UIInterfaceOrientation : UIEdgeInsets]]?

// MARK: - 其他
public var dateTimeFormatStyle1: String { "yyyy/MM/dd HH:mm:ss" }
