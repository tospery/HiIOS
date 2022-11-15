//
//  Textable.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public protocol Textable {
    func toString(_ value: Any?) -> String?
}

extension Textable {
    func toString(_ value: Any?) -> String? { nil }
}
