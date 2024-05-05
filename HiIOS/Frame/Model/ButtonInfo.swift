//
//  ButtonInfo.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/6.
//

import Foundation
import ObjectMapper_Hi

public struct ButtonInfo: Subjective {
    
    public var id = ""
    public var height: CGFloat?
    public var title: String?
    public var color: String?
    public var tintColor: String?
    public var enabled: Bool?
    public var target: String?

    public init() { }

    public init?(map: Map) { }
    
    public init(
        id: String = "",
        title: String? = nil,
        height: CGFloat? = nil,
        color: String? = nil,
        tintColor: String? = nil,
        enabled: Bool? = nil,
        target: String? = nil
    ) {
        self.id = id
        self.enabled = enabled
        self.title = title
        self.height = height
        self.color = color
        self.tintColor = tintColor
        self.target = target
    }

    mutating public  func mapping(map: Map) {
        id              <- map["id"]
        enabled         <- map["enabled"]
        height          <- map["height"]
        color           <- map["color"]
        tintColor       <- map["tintColor"]
        title           <- map["title"]
        target          <- map["target"]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(height)
        hasher.combine(color)
        hasher.combine(tintColor)
        hasher.combine(title)
        hasher.combine(target)
        hasher.combine(enabled)
    }

}
