//
//  Configuration.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/9.
//

import Foundation
import RealmSwift

public protocol ConfigurationType: ModelType {
    var localization: Localization { get }
}

public enum Localization: String, PersistableEnum {
    case chinese    = "zh-Hans"
    case english    = "en"
    
    public static let allValues = [chinese, english]
    
    public var preferredLanguages: [String] { [self.rawValue] }
}
