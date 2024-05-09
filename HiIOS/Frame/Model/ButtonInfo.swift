//
//  ButtonInfo.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/6.
//

import Foundation
import ObjectMapper

public enum ButtonStyle: Int, Codable {
    case plain
    case round
}

public struct ButtonInfo: Subjective {
    
    public var id = ""
    public var style = ButtonStyle.plain
    public var height: CGFloat?
    public var title: String?
    public var titleColor: String?
    public var backgroundColor: String?
    public var tintColor: String?
    public var enabled: Bool? = true
    public var target: String?

    public init() { }

    public init?(map: Map) { }
    
    public init(
        id: String = "",
        style: ButtonStyle = .plain,
        title: String? = nil,
        height: CGFloat? = nil,
        titleColor: String? = nil,
        backgroundColor: String? = nil,
        tintColor: String? = nil,
        enabled: Bool? = true,
        target: String? = nil
    ) {
        self.id = id
        self.style = style
        self.enabled = enabled
        self.title = title
        self.height = height
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.target = target
    }

    mutating public  func mapping(map: Map) {
        id                  <- map["id"]
        style               <- map["style"]
        enabled             <- map["enabled"]
        height              <- map["height"]
        titleColor          <- map["titleColor"]
        backgroundColor     <- map["backgroundColor"]
        tintColor           <- map["tintColor"]
        title               <- map["title"]
        target              <- map["target"]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(style)
        hasher.combine(height)
        hasher.combine(titleColor)
        hasher.combine(backgroundColor)
        hasher.combine(tintColor)
        hasher.combine(title)
        hasher.combine(target)
        hasher.combine(enabled)
    }

}
