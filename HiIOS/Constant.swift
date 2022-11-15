//
//  Constant.swift
//  HiSwift
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit

// MARK: - 编译常量
/// 判断当前是否debug编译模式
public var isDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}