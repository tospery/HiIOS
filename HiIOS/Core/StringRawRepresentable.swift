//
//  StringRawRepresentable.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import SwifterSwift

public protocol StringRawRepresentable {
    var stringRawValue: String { get }
}

extension StringRawRepresentable where Self: RawRepresentable, Self.RawValue == String {
    var stringRawValue: String { return self.rawValue }
}

extension StringRawRepresentable where Self: RawRepresentable, Self.RawValue == Int {
    var stringRawValue: String { return self.rawValue.string }
}

