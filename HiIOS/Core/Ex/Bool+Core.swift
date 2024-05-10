//
//  Bool+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public protocol BooleanType {
    var boolValue: Bool { get }
}

extension Bool: BooleanType {
    public var boolValue: Bool { return self }
}
